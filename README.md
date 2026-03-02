Oto finalna, profesjonalna treść do Twojego pliku `README.md`. Skupiłem się na konkretach technicznych, które pokazują, że projekt to przemyślany system, a nie tylko luźne skrypty.

---

# NASA Battery Intelligence System

## Overview

Hybrid diagnostic framework developed in **MATLAB** for estimating the **State of Health (SOH)** and **Remaining Useful Life (RUL)** of Lithium-ion batteries. The system integrates high-performance Machine Learning regressors with a **Fuzzy Inference System (FIS)** to translate numerical predictions into actionable health assessments.

## Interactive Dashboard

The core of this project is a standalone application built via MATLAB's `uihtml` component, merging a heavy-duty computational backend with a modern web-based frontend.

### Technical Features:

* **Dual-Engine Prediction:** Real-time estimation of SOH (0-1 range) and RUL (remaining cycles) using optimized ML models.
* **Fuzzy Logic Integration:** A Sugeno-type controller (`ModelFuzzy3.fis`) evaluates battery condition based on SOH/RUL confidence intervals.
* **Web-Tech Frontend:** Responsive UI implemented in HTML5 and CSS3, utilizing bi-directional data synchronization with the MATLAB engine.

## Dataset & Engineering

The models are trained and validated using the **NASA Prognostics Data Repository** (Batteries: B0005, B0006, B0007, B0018).

### Data Pipeline:

* **Battery-Specific Splitting:** Validation is performed on entire unseen battery profiles to ensure zero data leakage and real-world generalizability.
* **Signal Processing:** Implementation of Tukey's fences for sensor noise reduction and current/voltage stabilization.
* **Feature Engineering:** Automated extraction of mean voltage, current loads, and temperature profiles from discharge cycles.

## Architecture

### Machine Learning Benchmarking

The `src/` directory contains a modular benchmarking suite comparing multiple architectures:

* **MLP (Neural Networks):** Multi-layer perceptrons for capturing complex, non-linear degradation.
* **LSBoost:** Gradient-boosted decision trees for high-precision regression.
* **Random Forest:** Ensemble method used for robust feature importance analysis.
* **Lasso & OLS:** Linear baselines used for performance benchmarking and "log1p" transformation testing.

### Fuzzy Inference System

To mitigate the "black-box" nature of ML, the **Fuzzy Logic** layer interprets raw output to classify health status into categorical states: `Słaba`, `Średnia`, or `Dobra`.

## Requirements & Execution

### Environment:

* **MATLAB** (R2021b or newer)
* **Statistics and Machine Learning Toolbox**
* **Fuzzy Logic Toolbox**

### Running the Project:

1. Clone the repository:
```bash
git clone https://github.com/TwojUsername/nasa-battery-intelligence-system.git

```


2. Navigate to the `/app` directory in MATLAB.
3. Execute the startup script:
```matlab
runBatteryApp.m

```
