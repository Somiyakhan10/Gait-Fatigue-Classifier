# Cloud Processing (free Google Colab)

Easiest route: upload the project ZIP to Colab and open `notebooks/colab_run.ipynb` (File -> Upload notebook), then run its cells in order.
The manual steps below do the same thing.

Use this if a dataset is too big for your disk (for example `duo_gait_raw`). Nothing paid is required.

1. Zip this project folder (without `data/` and `outputs/`) and upload it to Google Drive or directly to a Colab session.
2. In a new Colab notebook run:
```python
!unzip -q gait_project.zip -d /content && cd /content/gait_project
%cd /content/gait_project
!pip install -q -r requirements.txt
```
3. Optionally edit `config/config.yaml` (for example `datasets: [duo_gait_raw]`, `cloud.use_cloud: true`) using the Colab file editor.
4. Run:
```python
!python main.py --datasets duo_gait_raw --yes --export-zip
```
Colab's temporary disk is deleted when the session ends, so downloads never touch your computer.
5. Download the compact results (figures, tables, reports, model, features; no raw data):
```python
from google.colab import files
files.download("results_export.zip")
```
Same code and config are used locally and in Colab. Run small datasets locally in VS Code and big ones here.
Colab may be unable to reach some hosts or may disconnect after idle time; rerun and the resumable downloader continues.
