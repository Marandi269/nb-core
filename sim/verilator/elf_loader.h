#ifndef ELF_LOADER_H
#define ELF_LOADER_H

#include <stdint.h>
#include <string>
#include <vector>

// ELF文件加载器类
class ELFLoader {
public:
    struct MemorySegment {
        uint64_t vaddr;      // 虚拟地址
        uint64_t filesz;     // 文件中的大小
        uint64_t memsz;      // 内存中的大小
        std::vector<uint8_t> data;  // 段数据
    };

private:
    uint64_t entry_point_;
    std::vector<MemorySegment> segments_;
    bool is_loaded_;

public:
    ELFLoader();
    ~ELFLoader();

    // 加载ELF文件
    bool load(const char* filename);

    // 获取入口点地址
    uint64_t get_entry_point() const { return entry_point_; }

    // 获取所有内存段
    const std::vector<MemorySegment>& get_segments() const { return segments_; }

    // 检查是否已加载
    bool is_loaded() const { return is_loaded_; }

    // 打印ELF信息
    void print_info() const;
};

#endif // ELF_LOADER_H
