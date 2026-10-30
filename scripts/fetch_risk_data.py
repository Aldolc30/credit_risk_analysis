import os
from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine

load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

connection_string = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_string)

# 2. Tu Consulta 5 en formato de texto dentro de Python
consultas_proyectos = {
    "01_kpi_global" : """
        SELECT 
            COUNT(*) AS total_clientes,
            SUM(loan_amnt) AS total_cartera_usd,
            COUNT(CASE WHEN loan_status = 1 THEN 1 ELSE NULL END) AS clientes_morosos,
            SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS total_cartera_mora_usd,
            ROUND(
                (SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END)) / SUM(loan_amnt) * 100
            ,2) AS tasa_cartera_riesgo,
            ROUND(
                (COUNT(CASE WHEN loan_status = 1 THEN 1 END)::NUMERIC / COUNT(*)) * 100
            ,2) AS tasa_mora_clientes_pct
        FROM credit_risk
    """,
    "02_loan_grade_risk" : """
        SELECT 
            loan_grade,
            COUNT(*),
            SUM(loan_amnt) AS monto_total_prestado,
            ROUND(AVG(loan_int_rate),2) AS tasa_interes_promedio,
            COUNT(CASE WHEN loan_status = 1 THEN 1 END) AS cant_clientes_mora,
            ROUND(
                (COUNT(CASE WHEN loan_status = 1 THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
            ) AS tasa_mora_clientes
        FROM credit_risk
        GROUP BY loan_grade
        ORDER BY loan_grade ASC
    """,
    "03_vivienda_intent" : """
        SELECT 
            person_home_ownership,
            loan_intent,
            COUNT(*),
            SUM(loan_amnt) AS monto_total_prestado,
            ROUND(AVG(loan_int_rate), 2) AS tasa_interes_promedio,
            COUNT(CASE WHEN loan_status = 1 THEN 1 END) AS cant_cliente_mora,
            ROUND(
                (COUNT(CASE WHEN loan_status = 1 THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
            ) AS tasa_clientes_mora
        FROM credit_risk
        GROUP BY person_home_ownership, loan_intent
        ORDER BY person_home_ownership, tasa_clientes_mora DESC
    """,
    "04_historial_credito" : """
        SELECT
            cb_person_cred_hist_length,
            COUNT(*) AS cant_total_creditos,
            SUM(loan_amnt) AS total,
            ROUND(
                AVG(person_income), 2
            ) AS ingreso_promedio,
            ROUND(
                AVG(loan_amnt), 2
            ) AS monto_promedio_prestado,
            COUNT(CASE WHEN loan_status = 1 THEN 1 END) AS cant_cliente_mora,
            ROUND(
                (COUNT(CASE WHEN loan_status = 1 THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
            ) AS tasa_clientes_mora
        FROM credit_risk
        GROUP BY cb_person_cred_hist_length
        -- ORDER BY COUNT(*) DESC
        ORDER BY cant_total_creditos DESC
    """,
    "05_grupo_edad" : """
        SELECT 
            age_group,
            COUNT(*) AS cant_total_creditos,
            SUM(loan_amnt) AS total_monto_prestado,
            ROUND(AVG(person_income), 2) AS ingreso_promedio,
            COUNT(CASE WHEN loan_status = 1 THEN 1 END) AS cant_clientes_mora,
            ROUND(
                (SUM(CASE WHEN loan_status = 1 THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
            ) AS tasa_clientes_mora,
            ROUND(
                (SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END)) / SUM(loan_amnt) * 100
            ,2) AS tasa_cartera_riesgo
        FROM credit_risk
        GROUP BY age_group
        ORDER BY tasa_clientes_mora DESC
    """
}

try:
    # Creamos una carpeta recursiva para evitar errores
    os.makedirs("../outputs", exist_ok = True)
    # Como el nombre del reporte y la consulta están guardadas en un diccionario, usamos un bucle for para
    # iterar cada una de las 5 consultas con sus nombres (el mismo que usaremos como nombre de archivo de cada una)
    for nombre_reporte, sql_query in consultas_proyectos.items():
        print(f"Ejecutando y exportando: {nombre_reporte} ...")

        # Guardamos en un DataFrame cada consulta SQL y hacemos la conexión
        df = pd.read_sql(sql_query, con = engine)

        # Creamos una variable donde se almacena cada una de las rutas de las diferentes consultas
        ruta_archivo = f"../outputs/{nombre_reporte}.csv"

        # Convertimos el DataFrame a un archivo CSV y lo guardamos en su respectiva ruta
        df.to_csv(ruta_archivo, index = False)
    print("\n¡Listo! Las 5 consultas se han ejecutado y guardado automáticamente en la carpeta 'outputs/'.")
except Exception as e:
    print(f"Ocurrió un error en la exportación de informes: {e}")