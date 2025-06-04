# Can One Model Fit All? Evaluating Foundation Models for Time Series Forecasting Across Clinical Medicine

This repository contains the code, data processing scripts, and evaluation pipeline for our research on foundation models in clinical time series forecasting. We compare pre-trained transformer-based foundation models to traditional task-specific approaches across six forecasting tasks in multiple clinical settings.

## Abstract

Artificial intelligence (AI) is increasingly integrated into clinical medicine, with foundation models emerging as an alternative to task-specific models for forecasting longitudinal healthcare data. These models, pre-trained on large datasets, promise broad applicability across clinical domains, yet their real-world performance and generalizability remain underexplored.

To address this gap, we evaluated foundation and task-specific models across diverse clinical use cases, focusing on zero-shot performance, cross-hospital transportability, the impact of fine-tuning, and potential clinical implications. We used data from University Hospital Essen, Germany, two nearby regional hospitals, and the MIMIC-IV database to define six clinical time series use cases, including forecasting of vital signs, laboratory values, and hospital capacity.

Transformer-based foundation models were compared in zero-shot and fine-tuned settings to task-specific approaches, including neural networks, gradient boosting, AutoML ensembles, and statistical models. We also assessed predictive value for guiding treatment decisions by dichotomizing forecasts. Results suggest that foundation models are viable for clinical time series forecasting, particularly where generalizability is crucial. Their flexibility and zero-shot capabilities reduce the need for retraining, potentially lowering barriers to adoption.

## Repository Structure

```
clinical-foundation-forecasting/
├── data/                   # Scripts for loading and preprocessing clinical datasets
├── models/                 # Implementations and wrappers for all model architectures
├── training/               # Training and fine-tuning pipelines
├── evaluation/             # Evaluation metrics, plots, and comparison logic
├── use_cases/              # Definitions and configuration files for the six forecasting tasks
├── notebooks/              # Jupyter notebooks for visualization and exploration
├── results/                # Evaluation outputs and result summaries
├── requirements.txt        # Python dependencies
└── README.md               # Project overview
```

## Use Cases

We define six clinical forecasting tasks using time series data from hospital EHR systems:

1. Body temperature
2. Mean arterial pressure
3. Heart rate
4. Hemoglobin
5. Creatinine
6. CT-Scans

Each task is defined by a prediction target, time horizon, and relevant input variables.

## Models Compared

We compare the following model families:

- Foundation Models: Chronos, TimesFM, Time-LLM
- Tree-based Model: Gradient Boosting Machines (LightGBM)
- Deep Learning Model: N-BEATS
- Ensemble: AutoML with deep learning models
- Statistical Baselines: ARIMA, Naive

Both zero-shot and fine-tuned scenarios are evaluated. Fine-tuning is performed on each task separately.

## Datasets

This study uses data from the following sources:

- University Hospital Essen (structured EHR) as training data
- Prospective data from the University Hospital Essen as temporal validation cohort
- Two smaller hospitals in the same regional area
- MIMIC-IV database (public ICU data from Beth Israel Deaconess Medical Center)

All data are de-identified and preprocessed to uniform time-indexed tabular formats.

## Setup Instructions

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/clinical-foundation-forecasting.git
   cd clinical-foundation-forecasting
   ```

2. Create a virtual environment and install dependencies:

   ```
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. Train or evaluate a model:

   ```
   python training/train.py
   python evaluation/evaluate.py
   ```

## Citation

If you use this work in your own research, please cite:

```
@article{yourname2025foundationmodels,
  title={Can One Model Fit All? Evaluating Foundation Models for Time Series Forecasting Across Clinical Medicine.},
  author={Pucher, G., Dada, A., Agbodoyetin, A., Nensa, F., Schuler, M., Reinhardt, HC., Kleesiek, J., Sauer, CM.},
  year={2025}
}
```

## License

This repository is licensed under the MIT License. Note that access and use of MIMIC-IV and institutional data must comply with the respective data usage agreements and ethical approvals.
