# NonlinearGait
**Nonlinear Time-Series Analysis and Machine Learning for Fatigue-Related Changes in Human Gait**

![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-orange)
![pandas](https://img.shields.io/badge/pandas-data-150458)
![Tests](https://img.shields.io/badge/tests-passing-brightgreen)
![Data](https://img.shields.io/badge/data-PhysioNet%20%2B%20Zenodo-lightgrey)

**NonlinearGait** asks a simple question: *do nonlinear measures of walking add anything beyond ordinary summary statistics when you try to tell movement conditions apart?* 

It takes stride-by-stride gait recordings from two public datasets, computes conventional and nonlinear features in sliding windows, and compares machine-learning models built on each feature set. Every model is tested on people it has never seen (**leave-one-subject-out**), so windows from one person never end up in both training and test data.

The project downloads the data itself, processes it in a temporary folder, keeps only the derived features and results, and deletes the raw files afterwards. It runs efficiently on a laptop with very little free disk space.

---

## 📸 Results & Screenshots

*Note: The visual results below are generated using the real **DUO-GAIT** dataset (fatigued vs. rested walking).*

### 1. Terminal Execution
![Terminal Output](result/terminal_output.png)
*The pipeline successfully running in VS Code, showing model training and evaluation.*

### 2. Model Comparison (AUC)
![Model Comparison](result/model_comparison_auc.png)
*Comparison of Area Under the Curve (AUC) across Conventional, Nonlinear, and Hybrid feature sets. Hybrid models show robust performance.*

### 3. Participant-Level Accuracy
![Participant Accuracy](result/participant_level_accuracy.png)
*Held-out accuracy for each individual participant using Leave-One-Subject-Out (LOSO) validation to prevent data leakage.*

### 4. Feature Importance
![Feature Importance](result/feature_importance.png)
*Which biomechanical features drove the machine learning predictions. This highlights the contribution of nonlinear metrics.*

---

## ✨ Core Features

*   **Automatic Data Handling:** Downloads datasets, checks file integrity, extracts only the necessary files, and cleans up raw data. Interrupted downloads resume automatically.
*   **Conventional Features:** Mean, standard deviation, coefficient of variation, RMS, range, skewness, kurtosis, median absolute difference, dominant frequency, and spectral entropy.
*   **Nonlinear Features:** Sample Entropy (SampEn), Recurrence Quantification Analysis (RQA: RR, DET, L, Lmax, LAM, TT), largest Lyapunov exponent (Rosenstein method), and Detrended Fluctuation Analysis (DFA).
*   **Machine Learning Models:** Logistic Regression, SVM, Random Forest, Gradient Boosting (and XGBoost if installed). Each is trained on three feature sets: Conventional, Nonlinear, and Hybrid.
*   **Honest Validation:** Leave-one-subject-out (LOSO) testing, per-participant accuracy, bootstrap confidence intervals, and a paired statistical test comparing nonlinear vs. conventional features.
*   **Explainability:** Permutation importance and SHAP integration to explain which features drive the AI's decisions.
*   **Synthetic Demonstration Mode:** A built-in simulated dataset to test the software pipeline without downloading real data. Results are clearly labelled and saved separately.
*   **Encryption:** AES-256-GCM for datasets you are not allowed to leave unprotected. Keys are kept outside the project folder.
*   **Outputs:** A Markdown report, CSV tables for each feature family, and 300-dpi figures for every run.

---

## 📊 Summary of Scientific Results

### Dataset 1: DUO-GAIT (Fatigue vs. Rested)
*   **Participants:** 16 healthy adults (Stride time and stride length from foot sensors).
*   **Results:** Models performed close to chance (AUC roughly 0.47 to 0.59, per-participant accuracy 0.40 to 0.69). Permutation importances were near zero.
*   **Conclusion:** With these specific features and this sample size, no reliable fatigue signal was found. *This is a valuable negative result, not a failed run.*

### Dataset 2: PhysioNet Long-Term Recordings
*   **Participants:** 10 healthy adults (Spontaneous vs. metronome-paced walking).
*   **Results:** High classification performance (AUC up to 0.97). Paced walking showed weaker long-range correlation (DFA α ~0.6) compared to spontaneous walking (DFA α ~0.85).
*   **Conclusion:** Nonlinear features did not significantly improve on conventional ones for this specific task, though the hybrid set performed within noise of the conventional set.

---

## 🛠️ Installation & Setup

```bash
# 1. Clone the repository
git clone https://github.com/Somiyakhan10/NonlinearGait.git
cd NonlinearGait

# 2. Create a virtual environment
python -m venv .venv

# 3. Activate the environment
.venv\Scripts\activate          # Windows
source .venv/bin/activate       # macOS/Linux

# 4. Install dependencies
pip install -r requirements.txt

# 5. (Optional) Install SHAP and XGBoost
pip install shap xgboost
