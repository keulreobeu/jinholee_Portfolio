## 8. 년도별 재구매율(Retention Rate) by 이진호

-- customerNumber의 첫번째 year을 customerNumber의 각 year에 나눈 나머지를 반환해서 1이 나오면 연속구매 -> 2003 2004 2005 3개뿐이라면 가능 하지만 스케일이 커지면 안됨
-- customerNumber의 첫번째 year와 customerNumber의 두번째 year를 빼기, customerNumber의 두번째 year와 customerNumber의 새번째 year를 빼기 .... 반복 -> 1(또는 -1)이 나오면 카운트 
-- 그러면 연산을 하는것이 아니라 다음년도가 존재하면 다른값을 반환하는것이 좋다 생각함.

-- 유니크한 (customerNumber, year)에 대해서 test 집합에 가장 큰 값을 반환 
SELECT sq.customerNumber,
	   sq.orderYear,
	   MAX(test) AS retention,
	   round(sum(MAX(test)) OVER(PARTITION BY sq.orderYear) / 
       count(sq.customerNumber) OVER(PARTITION BY sq.orderYear) * 100, 2) AS retention_rate
FROM (SELECT customerNumber, year(o1.orderDate) AS orderYear,
	  CASE WHEN EXISTS (SELECT 1 FROM orders o2
						WHERE o2.customerNumber = o1.customerNumber
						AND year(o2.orderDate) = year(o1.orderDate) + 1
                        ) THEN 1 ELSE 0 END AS test
	  FROM orders o1
      ) AS sq
GROUP BY sq.customerNumber, sq.orderYear
ORDER BY 1;

SELECT
    sq.orderYear,
    ROUND(SUM(sq.retention) / COUNT(sq.customerNumber) * 100, 2) AS retention_rate
FROM (SELECT customerNumber, YEAR(o1.orderDate) AS orderYear,
	         MAX(CASE WHEN EXISTS (SELECT 1
								   FROM orders o2
								   WHERE o2.customerNumber = o1.customerNumber
								   AND YEAR(o2.orderDate) = YEAR(o1.orderDate) + 1
								  )THEN 1 ELSE 0 END
				) AS retention
	  FROM orders o1
	  GROUP BY customerNumber, YEAR(o1.orderDate)
	) AS sq
GROUP BY sq.orderYear
ORDER BY sq.orderYear;


-- 서브쿼리
-- customerNumber의 값에 +1 인 값이 자기 자신에게 있으면 test에 1을 반환
-- 이 값은 하나의 customerNumber의 값에 여러개의 test를 반환함.
SELECT customerNumber,
	   year(o1.orderDate) orderYear,
	   CASE WHEN EXISTS (SELECT 1 FROM orders o2
						 WHERE o2.customerNumber = o1.customerNumber
						 AND year(o2.orderDate) = year(o1.orderDate) + 1
                         ) THEN 1 ELSE 0 END AS test
FROM orders o1
ORDER BY customerNumber;



-- LEFT JOIN을 통해 country를 JOIN해주고
-- PARTITION BY 를 통해 국가별로 구분을 또 해줌.
# 9. 국가별 년도별 재구매율 조회 by 이진호
SELECT sq.customerNumber, 
	   sq.orderYear,
	   c.country,
	   MAX(test) retention,
	   count(c.country) OVER(PARTITION BY sq.orderYear, c.country) country_count,
	   round(sum(MAX(test)) OVER(PARTITION BY sq.orderYear, c.country) / 
       count(sq.customerNumber) OVER(PARTITION BY sq.orderYear, c.country) * 100, 2) AS retention_rate
FROM (SELECT o1.customerNumber, year(o1.orderDate) AS orderYear,
	  CASE WHEN EXISTS (SELECT 1 FROM orders o2
						WHERE o2.customerNumber = o1.customerNumber
						AND year(o2.orderDate) = year(o1.orderDate) + 1
                        ) THEN 1 ELSE 0 END AS test
	  FROM orders o1
      ) AS sq
LEFT JOIN customers c ON sq.customerNumber = c.customerNumber
GROUP BY sq.customerNumber, c.country, sq.orderYear
ORDER BY 3, 2, 1;

-- 이상함 값이 다르게나옴 다시확인
SELECT
    sq.orderYear,
    c.country,
    ROUND(SUM(sq.retention) / COUNT(sq.customerNumber) * 100, 2) AS retention_rate
FROM (SELECT o1.customerNumber, YEAR(o1.orderDate) AS orderYear,
             CASE WHEN EXISTS (SELECT 1 FROM orders o2
							   WHERE o2.customerNumber = o1.customerNumber
							   AND YEAR(o2.orderDate) = YEAR(o1.orderDate) + 1
							  ) THEN 1 ELSE 0 END AS retention
	  FROM orders o1
     ) AS sq
LEFT JOIN
    customers c ON sq.customerNumber = c.customerNumber
GROUP BY sq.orderYear, c.country
ORDER BY c.country, sq.orderYear;




## 뷰를 사용

CREATE OR REPLACE VIEW retention_view AS
SELECT customerNumber, YEAR(o1.orderDate) AS orderYear,
       CASE WHEN EXISTS (SELECT 1 FROM orders o2
                         WHERE o2.customerNumber = o1.customerNumber
                         AND YEAR(o2.orderDate) = YEAR(o1.orderDate) + 1
                        ) THEN 1 ELSE 0 END AS test
FROM orders o1
ORDER BY customerNumber;

SELECT rv.customerNumber,
	   rv.orderYear,
	   MAX(test) AS retention, 
	   round(sum(MAX(test)) OVER(PARTITION BY rv.orderYear) / 
       count(rv.customerNumber) OVER(PARTITION BY rv.orderYear) * 100, 2) AS retention_rate
FROM retention_view rv
GROUP BY rv.customerNumber, rv.orderYear
ORDER BY 1;


SELECT rv.customerNumber, 
	   rv.orderYear,
	   c.country,
	   MAX(test) retention,
	   count(c.country) OVER(PARTITION BY c.country) country_count, 
	   round(sum(MAX(test)) OVER(PARTITION BY rv.orderYear, c.country) / 
       count(rv.customerNumber) OVER(PARTITION BY rv.orderYear, c.country) * 100, 2) AS retention_rate
FROM retention_view rv
LEFT JOIN customers c ON rv.customerNumber = c.customerNumber
GROUP BY rv.customerNumber, c.country, rv.orderYear
ORDER BY 3, 2, 1;