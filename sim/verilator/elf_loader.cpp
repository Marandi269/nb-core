#include "elf_loader.h"
#include <fstream>
#include <iostream>
#include <cstring>
#include <elf.h>

ELFLoader::ELFLoader() : entry_point_(0), is_loaded_(false) {}

ELFLoader::~ELFLoader() {}

bool ELFLoader::load(const char* filename) {
    std::ifstream file(filename, std::ios::binary);
    if (!file) {
        std::cerr << "Error: Cannot open file " << filename << std::endl;
        return false;
    }

    // 读取ELF头
    Elf64_Ehdr ehdr;
    file.read(reinterpret_cast<char*>(&ehdr), sizeof(ehdr));

    if (file.gcount() != sizeof(ehdr)) {
        std::cerr << "Error: File too small to be ELF" << std::endl;
        return false;
    }

    // 验证ELF magic number
    if (ehdr.e_ident[EI_MAG0] != ELFMAG0 ||
        ehdr.e_ident[EI_MAG1] != ELFMAG1 ||
        ehdr.e_ident[EI_MAG2] != ELFMAG2 ||
        ehdr.e_ident[EI_MAG3] != ELFMAG3) {
        std::cerr << "Error: Not a valid ELF file" << std::endl;
        return false;
    }

    // 验证64位RISC-V
    if (ehdr.e_ident[EI_CLASS] != ELFCLASS64) {
        std::cerr << "Error: Not a 64-bit ELF file" << std::endl;
        return false;
    }

    if (ehdr.e_machine != EM_RISCV) {
        std::cerr << "Error: Not a RISC-V ELF file (machine type: "
                  << ehdr.e_machine << ")" << std::endl;
        return false;
    }

    entry_point_ = ehdr.e_entry;

    // 读取程序头表
    file.seekg(ehdr.e_phoff);
    for (int i = 0; i < ehdr.e_phnum; i++) {
        Elf64_Phdr phdr;
        file.read(reinterpret_cast<char*>(&phdr), sizeof(phdr));

        // 只加载PT_LOAD类型的段
        if (phdr.p_type == PT_LOAD) {
            MemorySegment seg;
            seg.vaddr = phdr.p_vaddr;
            seg.filesz = phdr.p_filesz;
            seg.memsz = phdr.p_memsz;

            // 读取段数据
            seg.data.resize(phdr.p_memsz, 0);
            if (phdr.p_filesz > 0) {
                std::streampos old_pos = file.tellg();
                file.seekg(phdr.p_offset);
                file.read(reinterpret_cast<char*>(seg.data.data()), phdr.p_filesz);
                file.seekg(old_pos);
            }

            segments_.push_back(seg);
        }
    }

    is_loaded_ = true;
    return true;
}

void ELFLoader::print_info() const {
    if (!is_loaded_) {
        std::cout << "No ELF file loaded" << std::endl;
        return;
    }

    std::cout << "ELF Information:" << std::endl;
    std::cout << "  Entry Point: 0x" << std::hex << entry_point_ << std::dec << std::endl;
    std::cout << "  Segments: " << segments_.size() << std::endl;

    for (size_t i = 0; i < segments_.size(); i++) {
        const auto& seg = segments_[i];
        std::cout << "    Segment " << i << ":" << std::endl;
        std::cout << "      Vaddr:  0x" << std::hex << seg.vaddr << std::dec << std::endl;
        std::cout << "      FileSz: " << seg.filesz << " bytes" << std::endl;
        std::cout << "      MemSz:  " << seg.memsz << " bytes" << std::endl;
    }
}
