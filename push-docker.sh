#!/bin/bash

# Get the current git hash (first 10 characters)
GIT_HASH=$(git rev-parse HEAD | cut -c1-10)

# Check if git hash was obtained successfully
if [ -z "$GIT_HASH" ]; then
    echo "Error: Failed to get git hash"
    exit 1
fi

# Check if the latest image exists
if ! docker image inspect liquidai/ruler:latest >/dev/null 2>&1; then
    echo "Error: liquidai/ruler:latest not found"
    echo "Please build the image first using build_docker_mt.sh"
    exit 1
fi

# Create version tag
VERSION_TAG="liquidai/ruler:$GIT_HASH"
echo "Tagging image with version: $VERSION_TAG"
docker tag liquidai/ruler:latest "$VERSION_TAG"

# Push both version tag and latest tag
echo "Pushing version tag..."
if ! docker push "$VERSION_TAG"; then
    echo "Error: Failed to push version tag"
    exit 1
fi

echo "Pushing latest tag..."
if ! docker push liquidai/ruler:latest; then
    echo "Error: Failed to push latest tag"
    exit 1
fi

echo "Successfully tagged and pushed:"
echo "- $VERSION_TAG"
echo "- liquidai/ruler:latest"
