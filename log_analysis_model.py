##log analysis model script
##descrription: the scripts creates an machine learning model for log analysis
#author: khushi jain
#date: 2024-10-01
#version: 1.0
#purpose : to create a ml model using isolation forest algorithm for log analysis which will analyse system_logs file and detect if any anamolies found , it will check for all the info , warning , error or critical logged line
#############################################

import pandas as pd   
from sklearn.ensemble import IsolationForest
import re

# read the log file
Log_file_path = 'system_logs.txt'

with open(Log_file_path, 'r') as file:
    Logs = file.readlines()

# function to parse log lines

data = []

for log in Logs:
    parts = log.strip().split(" ", 3)
    if len(parts)<4:
        continue
    timestamp = parts[0] + " " + parts[1]
    log_level = parts[2]    
    message = parts[3]
    data.append([timestamp, log_level, message])

df = pd.DataFrame(data, columns=['Timestamp', 'Log_Level', 'Message'])

df[timestamp] = pd.to_datetime(df['Timestamp'])

# Assign numeric scores to log levels
log_level_mapping = {'INFO': 1, 'WARNING': 2, 'ERROR': 3, 'CRITICAL': 4}
df['Log_Level_Score'] = df['Log_Level'].map(log_level_mapping)

# Add message length as a new feature
df['message_length'] = df['Message'].apply(len)

# AI Model for Anomaly Detection (Isolation Forest)
model = IsolationForest(contamination=0.1, random_state=42)
df["anomaly"] = model.fit_predict(df[["Log_Level_Score", "message_length"]])

#mark anomalies in a readable format
df["is_anomaly"] = df["anomaly"].apply(lambda x: "❌ Anomaly" if x == -1 else "✅ Normal")

#print only detected anomalies
anomalies = df[df["is_anomaly"] == "❌ Anomaly"]
print("\n🔍 **Detected Anomalies:**\n", anomalies)

