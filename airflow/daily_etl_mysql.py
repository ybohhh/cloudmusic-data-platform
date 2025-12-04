from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.operators.mysql import MySqlOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# Default arguments for enterprise reliability
default_args = {
    'owner': 'data_engineering',
    'depends_on_past': False,
    'email_on_failure': True,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'cloudmusic_daily_etl',
    default_args=default_args,
    description='Extract MySQL data, load to S3, transform in Redshift',
    schedule_interval='0 3 * * *', # Run daily at 3 AM
    start_date=days_ago(1),
    tags=['production', 'core_etl'],
) as dag:

    # Task 1: Check MySQL connection
    check_mysql = MySqlOperator(
        task_id='check_mysql_connection',
        mysql_conn_id='mysql_prod',
        sql='SELECT 1;'
    )

    # Task 2: Python extraction logic (Placeholder)
    def extract_to_s3():
        print("Extracting incremental data from streaming_events to S3 bucket...")
    
    extract_task = PythonOperator(
        task_id='extract_incremental_to_s3',
        python_callable=extract_to_s3
    )

    # Task 3: Trigger DBT (Placeholder)
    trigger_dbt = PythonOperator(
        task_id='trigger_dbt_models',
        python_callable=lambda: print("dbt run --select tag:daily")
    )

    # Define Dependencies
    check_mysql >> extract_task >> trigger_dbt
