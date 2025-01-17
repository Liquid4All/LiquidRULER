# Copyright (c) 2024, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import os
from typing import List
from tenacity import (
    retry,
    stop_after_attempt,
    wait_fixed,
    wait_random,
) 
import requests
from typing import List, Union



def select_tokenizer(tokenizer_type, tokenizer_path):
    if tokenizer_type == 'nemo':
        return NeMoSentencePieceTokenizer(model_path=tokenizer_path)
    elif tokenizer_type == 'hf':
        return HFTokenizer(model_path=tokenizer_path)
    elif tokenizer_type == 'openai':
        return OpenAITokenizer(model_path=tokenizer_path)
    elif tokenizer_type == 'gemini':
        return GeminiTokenizer(model_path=tokenizer_path)
    elif tokenizer_type == 'liquid':
        return LiquidTokenizer(model_path=tokenizer_path)
    else:
        raise ValueError(f"Unknown tokenizer_type {tokenizer_type}")


class NeMoSentencePieceTokenizer:
    """
    Tokenizer from NeMo SentencePieceTokenizer
    """
    def __init__(self, model_path) -> None:
        from nemo.collections.common.tokenizers.sentencepiece_tokenizer import SentencePieceTokenizer
        self.tokenizer = SentencePieceTokenizer(model_path=model_path)
    
    def text_to_tokens(self, text: str) -> List[str]:
        tokens = self.tokenizer.text_to_tokens(text)
        return tokens

    def tokens_to_text(self, tokens: List[int]) -> str:
        text = self.tokenizer.tokens_to_text(tokens)
        return text


class HFTokenizer:
    """
    Tokenizer from HF models
    """
    def __init__(self, model_path) -> None:
        from transformers import AutoTokenizer
        self.tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    
    def text_to_tokens(self, text: str) -> List[str]:
        tokens = self.tokenizer.tokenize(text)
        return tokens

    def tokens_to_text(self, tokens: List[int]) -> str:
        text = self.tokenizer.convert_tokens_to_string(tokens)
        return text


class OpenAITokenizer:
    """
    Tokenizer from tiktoken
    """
    def __init__(self, model_path="cl100k_base") -> None:
        import tiktoken
        self.tokenizer = tiktoken.get_encoding(model_path)

    def text_to_tokens(self, text: str) -> List[int]:
        tokens = self.tokenizer.encode(text)
        return tokens

    def tokens_to_text(self, tokens: List[int]) -> str:
        text = self.tokenizer.decode(tokens)
        return text


class GeminiTokenizer:
    """
    Tokenizer from gemini
    """
    def __init__(self, model_path="gemini-1.5-pro-latest") -> None:
        import google.generativeai as genai
        genai.configure(api_key=os.environ["GEMINI_API_KEY"])
        self.model = genai.GenerativeModel(model_path)
        
    @retry(wait=wait_fixed(60) + wait_random(0, 10), stop=stop_after_attempt(3))
    def text_to_tokens(self, text: str) -> List[int]:
        tokens = list(range(self.model.count_tokens(text).total_tokens))
        return tokens

    def tokens_to_text(self, tokens: List[int]) -> str:
        pass

class LiquidTokenizer:
    def __init__(self, model_path="lfm-3b",  api_token: str = None, base_url: str = None):
        """
        Initializes the TokenizerClient with the base URL of the tokenizer endpoint and the API token.

        :param base_url: The base URL of the tokenizer endpoint (e.g., 'http://localhost:8000').
        :param api_token: The API token for authorization.
        """
        self.base_url = base_url.rstrip("/")
        self.model = model_path

        self.base_url = base_url if base_url else os.environ["LIQUID_SERVER"]
        if self.base_url is None:
            raise ValueError("LIQUID_SERVER is missing from the environment variables.")

        self.api_token = api_token if api_token else os.environ["OPENAI_API_KEY"]
        if self.api_token is None:
            raise ValueError("OPENAI_API_KEY is missing from the environment variables.")

    @retry(wait=wait_fixed(60) + wait_random(0, 10), stop=stop_after_attempt(3))
    def text_to_tokens(self, text: str) -> List[int]:
        chat_messages = [{"role": "user", "content": text}]
        token_len = self.tokenize_chat(model=self.model, messages=chat_messages, add_generation_prompt=True, add_special_tokens=False)["token_count"]
        tokens = list(range(token_len))
        return tokens

    def tokens_to_text(self, tokens: List[int]) -> str:
        pass

    def _get_headers(self):
        return {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json",
        }

    def tokenize_completion(self, model: str, prompt: str, add_special_tokens: bool = True):
        """
        Sends a completion request to the tokenizer endpoint.

        :param model: The model name to use for tokenization.
        :param prompt: The prompt to tokenize.
        :param add_special_tokens: Whether to add special tokens during tokenization.
        :return: A dictionary containing the response fields that are present.
        """
        payload = {
            "model": model,
            "prompt": prompt,
            "add_special_tokens": add_special_tokens,
        }
        return self._send_request(payload)

    def tokenize_chat(
        self,
        model: str,
        messages: List[dict],
        add_generation_prompt: bool = True,
        add_special_tokens: bool = False,
    ):
        """
        Sends a chat request to the tokenizer endpoint.

        :param model: The model name to use for tokenization.
        :param messages: A list of chat messages to tokenize.
        :param add_generation_prompt: Whether to add a generation prompt during tokenization.
        :param add_special_tokens: Whether to add special tokens during tokenization.
        :return: A dictionary containing the response fields that are present.
        """
        payload = {
            "model": model,
            "messages": messages,
            "add_generation_prompt": add_generation_prompt,
            "add_special_tokens": add_special_tokens,
        }
        return self._send_request(payload)

    def _send_request(self, payload: dict):
        """
        Sends a request to the tokenizer endpoint with the given payload.

        :param payload: The payload to send.
        :return: A dictionary containing the response fields that are present.
        :raises: Exception if the request fails or the response format is unexpected.
        """
        url = f"{self.base_url}/tokenize"
        try:
            response = requests.post(url, json=payload, headers=self._get_headers())
            response.raise_for_status()
            data = response.json()

            result = {}
            if "count" in data:
                result["token_count"] = data["count"]
            if "max_model_len" in data:
                result["max_model_len"] = data["max_model_len"]
            if "tokens" in data:
                result["token_ids"] = data["tokens"]

            return result
        except requests.RequestException as e:
            raise Exception(f"Error communicating with tokenizer endpoint: {e}")
        except ValueError as e:
            raise Exception(f"Unexpected response from tokenizer endpoint: {e}")
