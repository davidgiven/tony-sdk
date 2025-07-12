#include <fmt/format.h>
#include <fstream>
#include <map>
#include <set>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

bool ischunkjump(const uint8_t* ptr)
{
    return ((ptr[0] == 0xa9) && (ptr[2] == 0x85) && (ptr[3] == 0x80) &&
            (ptr[4] == 0xa9) && (ptr[6] == 0x85) && (ptr[7] == 0x81) &&
            (ptr[8] == 0xa9) && (ptr[10] == 0x85) && (ptr[11] == 0x82) &&
            (ptr[12] == 0xa9) && (ptr[14] == 0x85) && (ptr[15] == 0x83) &&
            (ptr[16] == 0xa9) && (ptr[18] == 0x85) && (ptr[19] == 0x84) &&
            (ptr[20] == 0x4c) && (ptr[21] == 0x52) && (ptr[22] == 0x60));
}

bool ischunkcall(const uint8_t* ptr)
{
    return ((ptr[0] == 0xa9) && (ptr[2] == 0x85) && (ptr[3] == 0x80) &&
            (ptr[4] == 0xa9) && (ptr[6] == 0x85) && (ptr[7] == 0x81) &&
            (ptr[8] == 0xa9) && (ptr[10] == 0x85) && (ptr[11] == 0x82) &&
            (ptr[12] == 0xa9) && (ptr[14] == 0x85) && (ptr[15] == 0x83) &&
            (ptr[16] == 0xa9) && (ptr[18] == 0x85) && (ptr[19] == 0x84) &&
            (ptr[20] == 0x20) && (ptr[21] == 0xde) && (ptr[22] == 0x60));
}

int main(int argc, const char** argv)
{
    std::fstream ifs(argv[1]);
    const std::string data(std::istreambuf_iterator<char>{ifs}, {});

    std::map<uint32_t, uint32_t> callsites;
    std::set<std::pair<uint32_t, uint16_t>> chunks;
    chunks.insert(std::make_pair(0x07e4, 0x108));
    chunks.insert(std::make_pair(0x18f6, 318));
    for (auto i = 0; i < data.size() - 23; i++)
    {
        const uint8_t* p = (const uint8_t*)&data[i];
        if (ischunkjump(p) || ischunkcall(p))
        {
            uint32_t offset = (p[9] << 16) | (p[5] << 8) | p[1];
            uint16_t length = (p[17] << 8) | p[13];

            callsites[i] = offset;
            chunks.insert(std::make_pair(offset, length * 2));
        }
    }

    std::map<uint32_t, uint32_t> chunkaddresses;
    for (const auto& p : chunks)
        chunkaddresses[p.first] = p.second;

    {
        std::fstream ofs("extras/callgraph.dot", std::fstream::out);
        ofs << "digraph{\n";
        for (const auto& p : callsites)
        {
            auto i = chunkaddresses.lower_bound(p.first);
            if (i->first != p.first)
                i--;
            uint32_t start = i->first;
            uint32_t offset = p.first - start;
            if (offset >= i->second)
                ofs << fmt::format(
                    "// addr={:06x} offset={:04x}, chunk is {:06x}+{:04x}\n",
                    p.first,
                    offset,
                    start,
                    i->second);
            else
            {
                ofs << fmt::format(
                    "\"{:06x}\" -> \"{:06x}\";\n", start, p.second);
                if (ischunkcall((const uint8_t*)&data[p.first]))
                    ofs << fmt::format("\"{:06x}\" -> \"{:06x}\"; // reverse\n",
                        p.second,
                        start);
            }
        }
        ofs << "}\n";
    }

    for (const auto& p : chunks)
    {
        uint32_t offset = p.first;
        uint16_t length = p.second;

        std::fstream ofs(
            fmt::format("chunks/{:06x}.bin", offset), std::fstream::out);
        ofs << data.substr(offset, length);
    }

    return 0;
}
