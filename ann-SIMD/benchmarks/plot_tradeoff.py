#!/usr/bin/env python3
import os
import math
import struct
import zlib
import argparse

SQ = [
    (100, 0.99995, 1087.87),
    (200, 0.99995, 1387.96),
    (500, 0.99995, 1856.89),
    (1000, 0.99995, 2399.20),
    (2000, 0.99995, 3449.92),
    (5000, 0.99995, 5649.49),
    (10000, 0.99995, 10293.17),
    (50000, 0.99995, 30101.22),
    (100000, 0.99995, 45187.62),
]

PQ = [
    (100, 0.70930, 842.05),
    (200, 0.83835, 924.83),
    (500, 0.94740, 1178.43),
    (1000, 0.98355, 1520.52),
    (2000, 0.99550, 2488.09),
    (5000, 0.99980, 4180.43),
    (10000, 0.99995, 7268.55),
    (50000, 0.99995, 22651.73),
    (100000, 0.99995, 34630.02),
]

SERIAL = (8282.96, 0.99995)
FLAT_SIMD = (2596.54, 0.99995)


def plot_with_matplotlib(out_dir):
    import matplotlib.pyplot as plt

    def draw_one(data, title, out_file):
        p = [x[0] for x in data]
        recall = [x[1] for x in data]
        latency = [x[2] for x in data]

        plt.figure(figsize=(8, 5))
        plt.plot(latency, recall, marker="o", linewidth=2, label=title)
        for pi, x, y in zip(p, latency, recall):
            plt.annotate(f"p={pi}", (x, y), textcoords="offset points",
                         xytext=(5, 5), fontsize=8)
        plt.scatter([SERIAL[0]], [SERIAL[1]], marker="x", s=80,
                    color="red", label="Serial Flat")
        plt.xscale("log")
        plt.xlabel("Latency (us, log scale)")
        plt.ylabel("Recall@10")
        plt.title(title)
        plt.grid(True, which="both", linestyle="--", alpha=0.4)
        plt.legend()
        plt.tight_layout()
        plt.savefig(out_file, dpi=200)
        plt.close()

    draw_one(SQ, "SQ-SIMD Latency-Recall Tradeoff",
             os.path.join(out_dir, "fig1_sq_tradeoff.png"))
    draw_one(PQ, "PQ-SIMD Latency-Recall Tradeoff",
             os.path.join(out_dir, "fig2_pq_tradeoff.png"))

    plt.figure(figsize=(8, 5))
    for data, label in [(SQ, "SQ-SIMD"), (PQ, "PQ-SIMD")]:
        plt.plot([x[2] for x in data], [x[1] for x in data],
                 marker="o", linewidth=2, label=label)
    plt.scatter([SERIAL[0]], [SERIAL[1]], marker="x", s=80, label="Serial Flat")
    plt.scatter([FLAT_SIMD[0]], [FLAT_SIMD[1]], marker="s", s=60, label="Flat-SIMD")
    plt.xscale("log")
    plt.xlabel("Latency (us, log scale)")
    plt.ylabel("Recall@10")
    plt.title("SQ/PQ Latency-Recall Tradeoff")
    plt.grid(True, which="both", linestyle="--", alpha=0.4)
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(out_dir, "fig3_combined_tradeoff.png"), dpi=200)
    plt.close()


def write_png(path, w, h, pixels):
    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xffffffff)
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(pixels[y][x])
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(bytes(raw), 9)))
        f.write(chunk(b"IEND", b""))


def fallback_plot(data, path, y_min):
    w, h = 1000, 650
    img = [[bytearray((255, 255, 255)) for _ in range(w)] for _ in range(h)]

    def px_set(x, y, color):
        if 0 <= x < w and 0 <= y < h:
            img[y][x][:] = bytes(color)

    def line(x0, y0, x1, y1, color, width=1):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            for ox in range(-width, width + 1):
                for oy in range(-width, width + 1):
                    px_set(x0 + ox, y0 + oy, color)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def circle(cx, cy, r, color):
        for yy in range(cy - r, cy + r + 1):
            for xx in range(cx - r, cx + r + 1):
                if (xx - cx) * (xx - cx) + (yy - cy) * (yy - cy) <= r * r:
                    px_set(xx, yy, color)

    left, right, top, bottom = 90, 45, 70, 90
    xs = [row[2] for row in data] + [SERIAL[0]]
    ys = [row[1] for row in data] + [SERIAL[1]]
    lx0, lx1 = math.log10(min(xs) * 0.8), math.log10(max(xs) * 1.2)
    y_max = min(1.005, max(ys) + 0.01)

    def tx(lat):
        return int(left + (math.log10(lat) - lx0) / (lx1 - lx0) * (w - left - right))

    def ty(rec):
        return int(h - bottom - (rec - y_min) / (y_max - y_min) * (h - top - bottom))

    # grid and axes
    for t in [1000, 2000, 5000, 10000, 20000, 50000, 100000]:
        if min(xs) * 0.8 <= t <= max(xs) * 1.2:
            x = tx(t)
            line(x, top, x, h - bottom, (225, 225, 225), 0)
    for r in [0.7, 0.8, 0.9, 0.95, 0.98, 0.99, 1.0]:
        if y_min <= r <= y_max:
            y = ty(r)
            line(left, y, w - right, y, (225, 225, 225), 0)
    line(left, top, left, h - bottom, (0, 0, 0), 1)
    line(left, h - bottom, w - right, h - bottom, (0, 0, 0), 1)

    pts = [(tx(row[2]), ty(row[1])) for row in data]
    for a, b in zip(pts, pts[1:]):
        line(a[0], a[1], b[0], b[1], (20, 100, 200), 2)
    for x, y in pts:
        circle(x, y, 6, (20, 100, 200))
    sx, sy = tx(SERIAL[0]), ty(SERIAL[1])
    line(sx - 8, sy - 8, sx + 8, sy + 8, (220, 30, 30), 2)
    line(sx + 8, sy - 8, sx - 8, sy + 8, (220, 30, 30), 2)
    write_png(path, w, h, img)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", default="bench_results/android_termux_proot_ubuntu")
    args = parser.parse_args()
    out_dir = args.out_dir
    os.makedirs(out_dir, exist_ok=True)
    try:
        plot_with_matplotlib(out_dir)
    except ModuleNotFoundError:
        fallback_plot(SQ, os.path.join(out_dir, "fig1_sq_tradeoff.png"), 0.98)
        fallback_plot(PQ, os.path.join(out_dir, "fig2_pq_tradeoff.png"), 0.68)


if __name__ == "__main__":
    main()
