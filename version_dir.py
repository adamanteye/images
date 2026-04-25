import importlib.util
import pathlib
import sys


def main() -> None:
    version_file = pathlib.Path(sys.argv[1])
    spec = importlib.util.spec_from_file_location("version", version_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    parts = [str(module.major), str(module.minor)]
    patch = getattr(module, "patch", "")
    if str(patch) not in ("", "0", "None"):
        parts.append(str(patch))
    parts.append(str(module.status))
    print(".".join(parts))


if __name__ == "__main__":
    main()
