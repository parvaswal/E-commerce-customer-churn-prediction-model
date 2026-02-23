import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import roc_auc_score, classification_report
from sklearn.metrics import roc_curve

# ==============================
# 1. LOAD DATA
# ==============================

df = pd.read_csv("data/processed/customer_features.csv")

print("Dataset shape:", df.shape)
print("\nChurn distribution:")
print(df["churn"].value_counts())

# ==============================
# 2. HANDLE MISSING VALUES
# ==============================

df["recency_days"] = df["recency_days"].fillna(999)
df["total_orders"] = df["total_orders"].fillna(0)
df["total_spend"] = df["total_spend"].fillna(0)
df["avg_order_value"] = df["avg_order_value"].fillna(0)

print("\nNull check:")
print(df.isnull().sum())

# ==============================
# 3. FEATURES & TARGET
# ==============================

X = df.drop(["customer_id", "churn"], axis=1)
y = df["churn"]

# Safety check for one-class problem
if len(y.unique()) < 2:
    print("\nERROR: Only one class present in dataset.")
    print("Churn values:", y.unique())
    exit()

# ==============================
# 4. TRAIN-TEST SPLIT
# ==============================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print("\nTrain shape:", X_train.shape)
print("Test shape:", X_test.shape)

# ==============================
# 5. LOGISTIC REGRESSION
# ==============================

lr = LogisticRegression(
    max_iter=1000,
    class_weight="balanced"
)

lr.fit(X_train, y_train)

prob_lr = lr.predict_proba(X_test)[:, 1]
pred_lr = lr.predict(X_test)

print("\n===== Logistic Regression =====")
print("AUC:", roc_auc_score(y_test, prob_lr))
print(classification_report(y_test, pred_lr))

# ==============================
# 6. RANDOM FOREST
# ==============================

rf = RandomForestClassifier(
    n_estimators=200,
    class_weight="balanced",
    random_state=42
)

rf.fit(X_train, y_train)

prob_rf = rf.predict_proba(X_test)[:, 1]

print("\n===== Random Forest =====")
print("AUC:", roc_auc_score(y_test, prob_rf))

# ==============================
# 7. GRADIENT BOOSTING
# ==============================

gb = GradientBoostingClassifier(random_state=42)

gb.fit(X_train, y_train)

prob_gb = gb.predict_proba(X_test)[:, 1]

print("\n===== Gradient Boosting =====")
print("AUC:", roc_auc_score(y_test, prob_gb))

# ==============================
# 8. FINAL MODEL ON FULL DATA
# ==============================

final_model = LogisticRegression(
    max_iter=1000,
    class_weight="balanced"
)

final_model.fit(X, y)

df["churn_probability"] = final_model.predict_proba(X)[:, 1]

df[["customer_id", "churn_probability"]].to_csv(
    "output/churn_scores.csv",
    index=False
)

print("\nChurn scores exported to output/churn_scores.csv")
fpr, tpr, thresholds = roc_curve(y_test, prob_lr)

plt.figure()
plt.plot(fpr, tpr)
plt.plot([0,1], [0,1], linestyle="--")
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
plt.title("ROC Curve - Logistic Regression")
plt.show()