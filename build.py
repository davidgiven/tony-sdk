from build.ab import export, simplerule, filenamesof
from build.llvm import llvmrawprogram, llvmclibrary


def tonyprogram(
    name,
    chunks={},
    deps=[],
    cflags=[],
    ldflags=[],
):
    args = []
    for k, v in chunks.items():
        args += [k + ":"]
        args += filenamesof(v)

    simplerule(
        name=name + "_chunkfile",
        ins=["tools/genchunks.py"],
        outs=["=generated-chunks.ld"],
        commands=["$(PYTHON) $[ins[0]] " + (" ".join(args)) + " > $[outs[0]]"],
        label="GENCHUNKS",
    )

    llvmrawprogram(
        name=name,
        srcs=[inner for outer in chunks.values() for inner in outer],
        deps=[f".+{name}_chunkfile", ".+tony_lib"] + deps,
        cflags=cflags+["-mcpu=mosr65c02"],
        ldflags=ldflags + ["--no-check-sections", "-e0", "-L$[deps[0].dir]"],
        linkscript="./tony.ld",
    )


llvmclibrary(
    name="tony_lib",
    hdrs={"tony.inc": "./include/tony.inc", "zif.inc": "./include/zif.inc"},
)

tonyprogram(
    name="romimage",
    chunks={
        "_init": ["src/_init.S"],
        "_main": ["src/_main.S"],
        "_vwrite": ["src/_vwrite.S"],
    },
)

export(name="all", items={"tony.img": ".+romimage"})
