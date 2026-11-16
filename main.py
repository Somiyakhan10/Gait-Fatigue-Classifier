"""Run the research pipeline.   python main.py   (add --help to see all options)"""
import argparse
import subprocess
import sys
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))
import os
os.chdir(ROOT)                      # so relative paths in config work from anywhere

from src import env_check           # noqa: E402


def build_parser():
    ap = argparse.ArgumentParser(description="Nonlinear time-series analysis + machine learning for gait data.")
    g = ap.add_argument_group("what to run (default: real-data analysis of the datasets in config/config.yaml)")
    g.add_argument("--datasets", nargs="*", metavar="NAME", help="real datasets to run, e.g. umwdb duo_gait")
    g.add_argument("--synthetic", action="store_true", help="clearly-labelled simulated demo (software test only)")
    g.add_argument("--experiment", choices=["conventional", "nonlinear", "hybrid", "all"], default="all",
                   help="run only one feature set (A/B/C) instead of all")
    g.add_argument("--models", nargs="*", metavar="MODEL", help="subset: LogisticRegression SVM RandomForest GradientBoosting XGBoost")
    g.add_argument("--inspect", metavar="NAME", help="look inside a dataset (file names, columns) without analysing it")
    g.add_argument("--check", action="store_true", help="only check that the installation is complete")
    g.add_argument("--run-tests", action="store_true", help="run the automated tests")
    s = ap.add_argument_group("encryption (AES-256-GCM)")
    s.add_argument("--generate-key", action="store_true", help="create an encryption key outside the project folder")
    s.add_argument("--encrypt-folder", nargs=2, metavar=("SOURCE", "DEST"), help="encrypt every file in SOURCE into DEST")
    s.add_argument("--decrypt-file", nargs=2, metavar=("FILE.enc", "OUT"), help="decrypt one file")
    o = ap.add_argument_group("options")
    o.add_argument("--config", default="config/config.yaml", help="config file (can be a partial file, see experiments/)")
    o.add_argument("--registry", default="config/datasets.yaml")
    o.add_argument("--refresh", action="store_true", help="ignore saved features and recompute")
    o.add_argument("--keep-raw", action="store_true", help="keep downloaded files in data/downloads")
    o.add_argument("--no-cleanup", action="store_true", help="keep temporary files")
    o.add_argument("--yes", action="store_true", help="allow downloads larger than the size limit")
    o.add_argument("--export-zip", action="store_true", help="also write results_export.zip (for Colab)")
    o.add_argument("--debug", action="store_true", help="show full technical error details")
    return ap


def do_security(args):
    from src.security import key_management as km, encryption as enc
    km.load_dotenv()
    if args.generate_key:
        p = km.generate_key_file()
        print(f"Key created at: {p}\nIt is stored OUTSIDE the project. BACK IT UP somewhere safe (not in this folder or the ZIP).\n"
              "Without it, encrypted data cannot be recovered. The key itself is never displayed.")
    if args.encrypt_folder:
        src, dst = args.encrypt_folder
        n = enc.encrypt_folder(src, dst, **km.load_key())
        print(f"Encrypted {n} file(s) into {dst}. Your original files in {src} were NOT changed or deleted.\n"
              "Delete the originals yourself once you have checked the encrypted copies and your key backup.")
    if args.decrypt_file:
        enc.decrypt_file(args.decrypt_file[0], args.decrypt_file[1], **km.load_key())
        print(f"Decrypted to {args.decrypt_file[1]}. This plaintext file stays on disk until you delete it.")


def main():
    args = build_parser().parse_args()
    if args.run_tests:
        return subprocess.call([sys.executable, "-m", "pytest", "tests", "-v"])
    if not env_check.check(verbose=args.check):
        return 2
    if args.check:
        return 0
    try:
        if args.generate_key or args.encrypt_folder or args.decrypt_file:
            do_security(args)
            return 0

        from src.data.dataset_metadata import load_config, load_registry
        from src import pipeline
        cfg, reg = load_config(args.config), load_registry(args.registry)

        if args.inspect:
            from src.data.dataset_manager import DatasetManager
            from src.data.temporary_processing import temp_workspace
            if args.inspect not in reg:
                print(f"Unknown dataset '{args.inspect}'. Available: {', '.join(reg)}")
                return 2
            with temp_workspace(cfg["paths"]["temp_dir"], "inspect") as w:
                DatasetManager(cfg, reg[args.inspect], w, args.yes).inspect()
            return 0

        if args.synthetic:
            print("*** SYNTHETIC DEMO MODE: results are NOT real findings ***")
            out = pipeline.run_synthetic(cfg, args)
            print(f"\nSUCCESS (synthetic demo). Final report: {out / 'report.md'}")
            if args.export_zip:
                pipeline.export_zip(cfg)
            return 0

        done, failed = [], []
        names = args.datasets or cfg["datasets"]
        unknown = [n for n in names if n not in reg]
        if unknown:
            print(f"Unknown dataset name(s): {', '.join(unknown)}. Available: {', '.join(reg)}")
            return 2
        for name in names:
            print(f"\n=== {reg[name].describe()}")
            try:
                out = pipeline.run_real(cfg, reg, name, args)
                done.append((name, out))
            except Exception as e:
                failed.append(name)
                print(f"\n[FAILED] {name}: {e}")
                if args.debug:
                    traceback.print_exc()
        if args.export_zip:
            pipeline.export_zip(cfg)
        print("\n" + "=" * 70)
        for name, out in done:
            print(f"SUCCESS  {name}: final report -> {Path(out) / 'report.md'}")
        for name in failed:
            print(f"FAILED   {name}: see the message above (re-run with --debug for technical details)")
        if failed:
            print("\nNo results were substituted for the failed dataset(s). Common causes: no internet, a blocked website,\n"
                  "or file/column names that differ from config/datasets.yaml (try: python main.py --inspect <name>).\n"
                  "To test the software itself with clearly-labelled simulated data:  python main.py --synthetic")
        return 1 if failed else 0
    except Exception as e:
        print(f"\nERROR: {e}")
        print("Re-run with --debug for technical details.")
        if args.debug:
            traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
