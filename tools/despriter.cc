#include <fmt/format.h>
#include <fstream>
#include <map>
#include <set>
#include <vector>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char** argv)
{
    std::fstream flashrom(argv[1]);
    const std::vector<uint8_t> data(
        std::istreambuf_iterator<char>{flashrom}, {});

    std::fstream maskrom(argv[2]);
    const std::vector<uint8_t> rom(std::istreambuf_iterator<char>{maskrom}, {});

    uint8_t palette[256][3];
    for (int i = 0; i < 256; i++)
    {
        uint16_t rgb16 = rom[0x1357 + i] | (rom[0x1257 + i] << 8);
        float b = (float)(rgb16 & 0x1f) / (float)0x1f;
        float g = (float)((rgb16 >> 5) & 0x3f) / (float)0x3f;
        float r = (float)((rgb16 >> 11) & 0x1f) / (float)0x1f;
        palette[i][0] = 255.0 * r;
        palette[i][1] = 255.0 * g;
        palette[i][2] = 255.0 * b;
    }

    auto read3 = [&](uint32_t o)
    {
        return data[o + 0] | (data[o + 1] << 8) | (data[o + 2] << 16);
    };

    uint32_t spritetable = read3(0);
    fmt::print("sprite table at 0x{:06x}\n", spritetable);

    int index = 0;
    for (;;)
    {
        uint32_t sprite = read3(spritetable + 3 * index);
        if (sprite == 0xffffff)
            break;

        uint8_t w = data[sprite + 0];
        uint8_t flags = data[sprite + 1];
        uint8_t h = data[sprite + 2];

        {
            fmt::print(
                "sprite 0x{:04x} at 0x{:06x} ({}) ", index, sprite, sprite);
            fmt::print("w={} h={} flags=0x{:02x}\n", w, h, flags);

            std::fstream xpm(
                fmt::format("sprites/{:04x}.xpm", index), std::fstream::out);
            xpm << "/* XPM */\n";
            xpm << "static char * image[] = {\n";
            xpm << fmt::format("\"{} {} 256 2\",\n", w, h);
            for (int i = 0; i < 255; i++)
                xpm << fmt::format("\"{:02x} c #{:02x}{:02x}{:02x}\",\n",
                    i,
                    palette[i][0],
                    palette[i][1],
                    palette[i][2]);
            xpm << fmt::format("\"ff c None\",\n");

            std::vector<std::vector<uint8_t>> scanlines;
            int offset = 4;
            for (int y = 0; y < h; y++)
            {
                /* Read the data. */

                uint8_t len = data[sprite + offset] - 4;
                std::vector<uint8_t> scanline(len);
                for (int i = 0; i < len; i++)
                    scanline[i] = data[sprite + offset + 2 + i];

                offset += len + 4;

                /* Render the data. */

                xpm << "\"";
                int inptr = 0;
                int outptr = 0;
                uint8_t b;
                while (outptr < w)
                {
                    if (inptr == scanline.size())
                        b = 0xff;
                    else
                        b = scanline[inptr++];
                    int count = 1;
                    if (!b)
                    {
                        if (inptr == scanline.size())
                            break;
                        b = scanline[inptr++];
                        count = scanline[inptr++];
                    }

                    outptr += count;
                    while (count--)
                        xpm << fmt::format("{:02x}", b);
                }
                while (outptr < w)
                {
                    xpm << fmt::format("{:02x}", b);
                    outptr++;
                }

                xpm << "\",\n";
            }
            xpm << "};\n";

            if (false)
            {
                std::fstream ofs(fmt::format("sprites/{:04x}.bin", index),
                    std::fstream::out);

                for (int i = 0; i < offset; i++)
                    ofs.put(data[sprite + i]);
            }
        }

        index++;
    }

    return 0;
}
