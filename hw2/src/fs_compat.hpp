#pragma once

#if defined(__has_include)
#if __has_include(<filesystem>)
#include <filesystem>
namespace fs = std::filesystem;
#elif __has_include(<experimental/filesystem>)
#include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
#else
#error "A filesystem implementation is required."
#endif
#else
#include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
#endif
