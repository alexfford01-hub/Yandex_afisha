/* 1) Получение общих данных
Вычислите общие значения ключевых показателей сервиса за весь период:
общая выручка с заказов ;
количество заказов ;
средняя стоимость заказа ;
общее число уникальных клиентов.

Напишите запрос для вычисления этих значений. Поскольку данные представлены в российских рублях и казахстанских 
тенге,то значения посчитайте в разрезе каждой валюты. Результат отсортируйте по убыванию значения 
общего числа уникальных клиентов.*/

SELECT currency_code,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT user_id) AS total_users
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_revenue DESC;



/* 2) Изучение распределения выручки в разрезе устройств
Для заказов в рублях вычислите распределение выручки и количества заказов по типу устройства.
Результат должен включать поля:
тип устройства;
общая выручка с заказов;
количество заказов;
средняя стоимость заказа;
доля выручки для каждого устройства от общего значения, округлённая до трёх знаков после точки.
Результат отсортируйте по убыванию значения в поле revenue_share.*/

-- Настройка параметра synchronize_seqscans важна для проверки
WITH set_config_precode AS (
  SELECT set_config('synchronize_seqscans', 'off', true)
)
-- Напишите ваш запрос ниже
SELECT device_type_canonical,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       ROUND(SUM(revenue)::NUMERIC / (SELECT SUM(revenue)
   FROM afisha.purchases AS ps
   WHERE currency_code = 'rub')::NUMERIC, 3)
    AS revenue_share
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY device_type_canonical
ORDER BY revenue_share DESC; 



/*  3) Изучение распределения выручки в разрезе типа мероприятий
Для заказов в рублях вычислите распределение количества заказов и их выручку в зависимости от
типа мероприятия. Результат должен включать поля:
тип мероприятия;
общая выручка с заказов;
количество заказов;
средняя стоимость заказа;
уникальное число событий (по их коду);
среднее число билетов в заказе;
средняя выручка с одного билета;
доля выручки от общего значения, округлённая до трёх знаков после точки.
Результат отсортируйте по убыванию значения количества заказов. */

SELECT event_type_main,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT event_name_code) AS total_event_name,
       AVG(tickets_count) AS avg_tickets,
       SUM(revenue) / SUM(tickets_count) AS avg_ticket_revenue,
       ROUND(SUM(revenue)::NUMERIC  /
             (SELECT SUM(revenue)
              FROM afisha.purchases AS ps
              WHERE currency_code = 'rub')::NUMERIC, 3) AS revenue_share
FROM afisha.purchases
JOIN afisha.events ON afisha.purchases.event_id = afisha.events.event_id
WHERE currency_code = 'rub'
GROUP BY event_type_main
ORDER BY total_orders DESC;



/* 4) Динамика изменения значений
Для заказов в рублях вычислите изменение выручки, количества заказов, уникальных клиентов и средней стоимости 
одного заказа в недельной динамике. Результат должен включать поля:
неделя;
суммарная выручка;
число заказов;
уникальное число клиентов;
средняя стоимость одного заказа.
Результат отсортируйте по возрастанию значения в поле неделя.*/

SELECT 
    (DATE_TRUNC('week', created_dt_msk) :: date) AS week, -- Получаем начало недели
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    SUM(revenue) / COUNT(order_id) AS revenue_per_order
FROM 
    afisha.purchases
WHERE 
    currency_code = 'rub'
GROUP BY 
    week
ORDER BY 
    week ASC;



/* 5) Выведите топ-7 регионов по значению общей выручки, включив только заказы за рубли.
 Результат должен включать поля:
название региона;
суммарная выручка ;
число заказов ;
уникальное число клиентов ;
количество проданных билетов ;
средняя выручка одного билета .
Результат отсортируйте по убыванию значения в поле число заказов;.*/

SELECT 
    region_name,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    SUM(tickets_count) AS total_tickets,
    SUM(revenue) / SUM(tickets_count) AS one_ticket_cost
FROM 
    afisha.purchases
 JOIN afisha.events USING(event_id)
 JOIN afisha.city USING(city_id)
 JOIN afisha.regions USING(region_id)
WHERE 
    currency_code = 'rub'
GROUP BY 
    region_name
ORDER BY 
    total_revenue DESC
LIMIT 7;
