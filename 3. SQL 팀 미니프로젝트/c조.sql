## 1. 일별/월별/년도별 매출액 조회
-- 매출액 = quantityOrdered * priceEach

-- 1.1 일별
SELECT orderdate AS "일별", sum(quantityOrdered * priceEach) total_sales
FROM orders o
	LEFT JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY o.orderDate;

-- 1.2 월별
SELECT substr(orderDate, 1, 7) AS "월별", 
	   sum(quantityOrdered * priceEach) total_sales
FROM orders o 
	LEFT JOIN orderdetails od
	ON o.orderNumber = od.orderNumber
GROUP BY substr(orderDate, 1, 7);

-- 1.3 연별
SELECT substr(orderDate, 1, 4) AS "연별", 
	   sum(quantityOrdered * priceEach) total_sales
FROM orders o 
	LEFT JOIN orderdetails od
	ON o.orderNumber = od.orderNumber
GROUP BY substr(orderDate, 1, 4);



## 2. 일별/월별/년도별 구매자 수, 구매 건수 조회
-- 2.1 일별
SELECT orderDate AS "일별", 
	   count(distinct(customerNumber)) AS '구매자 수', 
	   count(*) AS '구매건 수'
FROM orders
GROUP BY orderDate;

-- 2.2 월별
SELECT substr(orderDate, 1, 7) AS "월별", 
	   count(distinct(customerNumber)) AS '구매자 수', 
	   count(*) AS '구매건 수'
FROM orders
GROUP BY substr(orderDate, 1, 7);

-- 2.3 연별
SELECT substr(orderDate, 1, 4) AS "연별", 
	   count(distinct(customerNumber)) AS '구매자 수', 
	   count(*) AS '구매건 수'
FROM orders
GROUP BY substr(orderDate, 1, 4);



## 3. 년도별 인당 매출액(AMV)
SELECT substr(orderDate, 1, 4) AS "연별", 
	   count(distinct customerNumber) AS '고객 수',
	   sum(quantityOrdered * priceEach) AS '총 매출액',
	   round(sum(quantityOrdered * priceEach) / count(distinct customerNumber), 2) AS '인당 매출액'
FROM orders o LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY substr(orderDate, 1, 4);



## 4. 년도별 건당 매출액(ATV)
SELECT substr(orderDate, 1, 4) AS "연별",
	   count(distinct(o.orderNumber)) AS "주문 건수",
	   sum(quantityOrdered * priceEach) AS '총 매출액',
	   round(sum(quantityOrdered * priceEach) / count(distinct(o.orderNumber)),2) AS '건당 매출액'
FROM orders o LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY substr(orderDate, 1, 4);



## 5. 국가별, 도시별 매출액 조회
-- 동일한 작업, 테이블 사용 -> view 업데이트
CREATE OR REPLACE VIEW country_view
AS
SELECT c.customerNumber, c.country as country_name, c.city as city_name,
	   o.orderNumber, 
	   od.priceEach as price, od.quantityOrdered as quantity
FROM customers c INNER JOIN orders o ON c.customerNumber = o.customerNumber
				 INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber;

-- 5.1 국가별 매출액 조회
SELECT country_name, sum(quantity * price) total_sales
FROM country_view
GROUP BY country_name
ORDER BY 2 DESC;

-- 5.2 도시별 매출액 조회
SELECT city_name, sum(quantity * price) total_sales
FROM country_view 
GROUP BY city_name
ORDER BY 2 DESC;

-- 5.3 국가별, 도시별 매출액 조회
SELECT country_name, city_name, sum(quantity * price) total_sales
FROM country_view 
GROUP BY country_name, city_name
ORDER BY 1, 3 DESC;

## 6. 북미(USA. Canada) vs 비북미 매출액 비교조회
SELECT CASE WHEN country_name IN ('USA', 'Canada') THEN 'North_America'
			ELSE 'The_others' END AS country_group,
       sum(quantity * price) total_sales,
       round(sum(quantity * price) / sum(sum(quantity * price)) over()* 100, 2) pct_of_total
FROM country_view
GROUP BY country_group;



## 7. 국가별 매출액 TOP 5 및 순위 조회
SELECT country_name, total_sales, rnk
FROM (SELECT country_name, sum(quantity * price) as total_sales,
		 	 rank() OVER(order by sum(quantity * price) desc) rnk
	  FROM country_view
      GROUP BY country_name) t
WHERE rnk <= 5;



## 8. 년도별 재구매율(Retention Rate)

SELECT sq.customerNumber, -- 손님 번호
	   sq.orderYear,
	   MAX(test) AS retention, -- 유니크한 (customerNumber, year)에 대해서 test에 1이 있으면 1을 반환 아니면 0을 반환
	   round(sum(MAX(test)) OVER(PARTITION BY sq.orderYear) / count(sq.customerNumber) OVER(PARTITION BY sq.orderYear) * 100, 2) AS retention_rate
FROM (SELECT customerNumber, year(o1.orderDate) AS orderYear,
	  CASE WHEN EXISTS (SELECT 1 FROM orders o2
						WHERE o2.customerNumber = o1.customerNumber
						AND year(o2.orderDate) = year(o1.orderDate) + 1
                        ) THEN 1 ELSE 0 END AS test
	  FROM orders o1
      ) AS sq
GROUP BY sq.customerNumber, sq.orderYear
ORDER BY 1;

-- 서브쿼리
SELECT
	   year(o1.orderDate) year,
	   CASE WHEN EXISTS (SELECT 1 FROM orders o2
						 WHERE o2.customerNumber = o1.customerNumber
						 AND year(o2.orderDate) = year(o1.orderDate) + 1
                         ) THEN 1 ELSE 0 END AS test
FROM orders o1
ORDER BY customerNumber;




# 9. 국가별 년도별 재구매율 조회
 -- LEFT JOIN을 뷰로 만들어서 사용해두 될듯
SELECT sq.customerNumber, 
	   sq.orderYear,
	   c.country,
	   MAX(test) retention,
	   count(c.country) OVER(PARTITION BY sq.orderYear, c.country) country_count, -- PARTITION BY로 국가별로 나눠 count함
	   round(sum(MAX(test)) OVER(PARTITION BY sq.orderYear, c.country) / count(sq.customerNumber) OVER(PARTITION BY sq.orderYear, c.country) * 100, 2) AS retention_rate
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


# 10. 미국의 베스트셀러 TOP 5 제품, 매출액, 순위 정보 조회

-- 제품명 / 매출액 
SELECT p.productName "제품명" ,
	   sum(od.quantityOrdered * od.priceEach) "매출액"
FROM products p
	left join orderdetails od
	on p.productCode = od.productCode
	left join orders o
	on od.orderNumber = o.orderNumber
	GROUP BY p.productName;
    
-- 제품명/ 매출액 / 순위
SELECT p.productName "제품명" ,
	   sum(od.quantityOrdered *od.priceEach) "매출액",
       rank() over (order by sum(od.quantityOrdered *od.priceEach) desc) "순위"
FROM products p
	left join orderdetails od
	on p.productCode = od.productCode
	left join orders o
	on od.orderNumber = o.orderNumber
	GROUP BY p.productName;
    
-- 제품명/ 매출액 / 순위 / 나라
SELECT c.country "국가",
	   p.productName "제품명" ,
	   sum(od.quantityOrdered *od.priceEach) "매출액",
       rank() over (order by sum(od.quantityOrdered *od.priceEach) desc) "순위"
FROM products p
	left join orderdetails od
	on p.productCode = od.productCode
	left join orders o
	on od.orderNumber = o.orderNumber
	left join customers c
	on o.customerNumber = c.customerNumber
	where c.country = 'USA'
	GROUP BY p.productName;
    
-- view 작성
CREATE OR REPLACE VIEW best_view
AS
SELECT c.customerNumber, c.country, 
	   o.orderNumber,
       od.quantityOrdered, od.priceEach, 
       p.productCode, p.productName
FROM  customers c INNER JOIN orders o ON c.customerNumber = o.customerNumber
                  INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
				  INNER JOIN products p ON od.productCode = p.productCode;

-- 서브쿼리를 이용한 최종 쿼리
SELECT *
FROM (SELECT productName "제품명" ,
             sum(quantityOrdered * priceEach) "매출액", 
             rank() over (order by sum(quantityOrdered * priceEach) desc) "순위"
	  FROM best_view
	  WHERE country = 'USA'
	  GROUP BY productName) rankings
WHERE 순위 <= 5; 



# 10. 가입자 이탈율(Churn Rate) 조회

-- 마지막 구매일이 90일 이상 지난 고객
SELECT customerNumber AS '고객번호',
	   max(orderDate) AS '최종구매일',		-- 고객별 마지막 구매일
	   datediff('2005-06-01', max(orderDate)) AS '경과날짜',		-- 특정시점과의 차이(마지막 구매일로부터의 경과 일수)
	   CASE WHEN datediff('2005-06-01', max(orderDate)) >= 90 THEN '높음'
															  ELSE '낮음'
															  END AS'이탈 가능성'		-- 마지막 구매일이 90일 이상 지난 고객의 이탈 가능성
FROM orders
GROUP BY customerNumber;

-- 마지막 구매일이 90일 이상 지난 총 고객의 비율
SELECT CASE WHEN datediff('2005-06-01', 최종구매일) >= 90 THEN '높음'
														ELSE '낮음'
														END AS '이탈 가능성',
		count(*) AS '총 고객 수',														-- 마지막 구매일이 90일 이상 지난 총 고객 수
		round(count(*) / (SELECT count(DISTINCT customerNumber) FROM orders) * 100,2) AS '고객 비율(%)'
FROM (SELECT customerNumber,
			max(orderDate) AS '최종구매일'
	  FROM orders
	  GROUP BY customernumber) t
GROUP BY 1;


#####################################
CREATE OR REPLACE VIEW inner_view
AS
SELECT c.customerNumber, c.city as city_name, c.country as country_name, o.orderNumber, o.orderDate, 
		od.quantityOrdered as quantity, od.priceEach as price, p.productCode, p.productName
FROM  customers c INNER JOIN orders o ON c.customerNumber = o.customerNumber
					INNER join orderdetails od ON o.orderNumber = od.orderNumber
                    INNER join products p ON od.productCode = p.productCode;


SELECT count(*) FROM inner_view;

-- 예시1)
SELECT CASE WHEN country_name IN ('USA', 'Canada') THEN 'North_America'
													ELSE 'The_others' 
			END AS country_group,
       sum(quantity * price) total_sales,
       round(sum(quantity * price) / sum(sum(quantity * price)) over()* 100, 2) pct_of_total
FROM inner_view
GROUP BY country_group;

-- 예시 2)
SELECT city_name, sum(quantity * price) total_sales
FROM  inner_view
GROUP BY city_name
ORDER BY 2 DESC;
