cd scripts/
bash run.sh lfm-3b synthetic

calculate_average() {
    echo "Average score:"
    python3 -c 'import sys,csv; print(sum(float(x) for x in next(csv.reader(sys.stdin))[1:])/13)' <<< $(sed -n '3p' "$1")
}

# See results in benchmark_root
echo "Context length: 32768"
calculate_average benchmark_root/lfm-3b/synthetic/32768/pred/summary.csv
echo

echo "Context length: 16384"
calculate_average benchmark_root/lfm-3b/synthetic/16384/pred/summary.csv
echo

echo "Context length: 8192"
calculate_average benchmark_root/lfm-3b/synthetic/8192/pred/summary.csv
echo

echo "Context length: 4096"
calculate_average benchmark_root/lfm-3b/synthetic/4096/pred/summary.csv
