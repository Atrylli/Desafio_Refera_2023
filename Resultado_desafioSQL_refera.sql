/* Queries */
UPDATE service_order
SET datetime_execution_budget_approved = (
	SELECT MAX(created_at)
	FROM log_event
	WHERE title IN ('Or�amento aprovado', 'Or�amento aprovado pelo pagador')
	AND service_order.id = log_event.service_order_id
)
WHERE datetime_execution_budget_approved IS NULL;

UPDATE service_order
SET datetime_approved_cancelled = (
	SELECT TOP 1 created_at
	FROM log_event
	WHERE title IN ('Aprova��o cancelada', 'Aprova��o da finaliza��o cancelada')
	AND service_order.id = log_event.service_order_id
	ORDER BY created_at DESC 
),
datetime_execution_budget_approved = NULL
WHERE EXISTS (
	SELECT * 
	FROM log_event
	WHERE title IN ('Aprova��o cancelada', 'Aprova��o da finaliza��o cancelada')
	AND service_order.id = log_event.service_order_id
);

UPDATE service_order
SET datetime_first_budget_approved = (
	SELECT MIN(created_at)
	FROM log_event
	WHERE title IN ('Or�amento aprovado', 'Or�amento aprovado pelo pagador')
	AND service_order.id = log_event.service_order_id
)
WHERE datetime_first_budget_approved IS NULL; 

/* Contabilizando os or�amentos aprovados e cancelados (agrupados por m�s) em 2022*/
/* Quantidade de or�amentos aprovados */
SELECT COUNT(DISTINCT datetime_execution_budget_approved) qtd_mes FROM service_order 
WHERE datetime_execution_budget_approved BETWEEN '20220101' AND '20221231' AND datetime_execution_budget_approved IS NOT NULL
GROUP BY MONTH(datetime_execution_budget_approved), YEAR(datetime_execution_budget_approved)
ORDER BY MONTH(datetime_execution_budget_approved);
/* Quantidade de or�amentos cancelados */
SELECT COUNT(DISTINCT datetime_approved_cancelled) qtd_mes FROM service_order 
WHERE datetime_approved_cancelled BETWEEN '20220101' AND '20221231'
GROUP BY MONTH(datetime_approved_cancelled), YEAR(datetime_approved_cancelled)
ORDER BY MONTH(datetime_approved_cancelled);
