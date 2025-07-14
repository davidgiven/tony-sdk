#include <fmt/format.h>
#include <fstream>
#include <map>
#include <set>
#include <vector>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "math.h"
#include "stb_image.h"

const uint8_t palette[256][3] = {
#include "palette.h"
};

static double F(double t)
{
    if (t > 0.008856)
        return cbrt(t);
    else
        return (903.3 * t + 16.0) / 116.0;
}

static void rgb_to_lab(
    uint8_t r, uint8_t g, uint8_t b, double& L, double& A, double& B)
{
    double fr = r / 255.0;
    double fg = g / 255.0;
    double fb = b / 255.0;

    double X = 0.412453 * fr + 0.357580 * fg + 0.180423 * fb;
    double Y = 0.212671 * fr + 0.715160 * fg + 0.072169 * fb;
    double Z = 0.019334 * fr + 0.119193 * fg + 0.950227 * fb;

    X = X / 95.0456;
    Y = Y / 100.0;
    Z = Z / 108.8754;

    L = 116.0 * F(Y) - 16.0;
    A = 500.0 * (F(X) - F(Y));
    B = 500.0 * (F(Y) - F(Z));
}

static double distance(double d1, double d2, double d3)
{
    return (d1 * d1) + (d2 * d2) + (d3 * d3);
}

static int find_closest_colour(uint8_t r, uint8_t g, uint8_t b)
{
    double tl, ta, tb;
    rgb_to_lab(r, g, b, tl, ta, tb);

    int selected = 0;
    double d = INFINITY;
    /* Don't select colour 255, white, as the tony uses this for transparency */
    for (int i = 0; i < 255; i++)
    {
        double sl, sa, sb;
        rgb_to_lab(palette[i][0], palette[i][1], palette[i][2], sl, sa, sb);

        sl -= tl;
        sa -= ta;
        sb -= tb;
        double sd = distance(sl, sa, sb);
        if (sd < d)
        {
            d = sd;
            selected = i;
        }
    }

    return selected;
}

int main(int argc, const char** argv)
{
    int w, h, n;
    const uint8_t* data = stbi_load(argv[1], &w, &h, &n, 4);

    std::fstream ofs(argv[2],
        std::fstream::out|std::fstream::binary);
    auto write = [&](uint8_t b)
    {
        ofs.put(b);
    };

    write(w);
    write(0);
    write(h);
    write(0);

    for (int y = 0; y < h; y++)
    {
        std::vector<uint8_t> row;

        uint8_t current;
        int count = 0;
        auto flush = [&]()
        {
            if ((current == 0x00) || (count > 3))
            {
                row.push_back(0);
                row.push_back(current);
                row.push_back(count);
            }
            else
            {
                while (count--)
                    row.push_back(current);
            }
            count = 0;
        };
        auto emit = [&](uint8_t b)
        {
            if (count && (b != current))
                flush();
            current = b;
            count++;
        };

        for (int x = 0; x < w; x++)
        {
            uint8_t r = *data++;
            uint8_t g = *data++;
            uint8_t b = *data++;
            uint8_t a = *data++;
            emit(find_closest_colour(r, g, b));
        }

        flush();
        write(row.size()+4);
        write(0);
        for (uint8_t b : row)
            write(b);
        write(row.size()+4);
        write(0);
    }

    return 0;
}
