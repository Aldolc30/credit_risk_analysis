-- ============================================================
-- Consulta 1: KPI Global de Cartera y Morosidad
-- Objetivo: Determinar la exposición total y el porcentaje en default
-- ============================================================

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

-- ============================================================
-- Consulta 2: Distribución de Riesgo por Calificación (loan_grade)
-- Objetivo: Evaluar la tasa de mora y la tasa de interés promedio por grado
-- ============================================================


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

-- ============================================================
-- Consulta 3: Influencia del factor socio-demográfico y del préstamo en el comportamiento de pago
-- Objetivo: Evaluar la tasa de mora y la tasa de interés promedio por vivienda y clase de prestamo
-- ============================================================

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

-- ============================================================
-- Consulta 4: Influencia del tiempo del score crediticio y del salario en el comportamiento de pago
-- Objetivo: Evaluar la tasa de mora por tiempo de historial creditio o por ingresos
-- ============================================================

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

-- ============================================================
-- Consulta 5: Análisis de riesgo por Grupo de Edad
-- Objetivo: Evaluar comportamiento de pago y volumen de créditos por etapa de vida
-- ============================================================

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