#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

constexpr std::string_view kColumnsSeparator = "   ";
constexpr std::string_view kInputPath = "input.txt";

[[nodiscard]]
auto read_file(const std::string_view& path) {
    std::ifstream file(kInputPath.data());
    std::vector<int> first_column;
    std::vector<int> second_column;
    for (std::string line; std::getline(file, line);) {
        std::istringstream iss(line);
        int first = 0, second = 0;
        iss >> first >> second;
        first_column.push_back(first);
        second_column.push_back(second);
    }
    return std::make_pair(first_column, second_column);
}

[[nodiscard]]
auto main() -> int {
    auto [first_column, second_column] = read_file(kInputPath);
    std::sort(first_column.begin(), first_column.end());
    std::sort(second_column.begin(), second_column.end());
    long long difference = 0;
    for (size_t i = 0; i < first_column.size(); ++i) {
        difference += std::abs(first_column[i] - second_column[i]);
    }
    std::cout << "Answer to part 1: " << difference << ".\n";
    return 0;
}
