-- EXERCISE 12
-- Formulate in natural language and implement 5 complex SQL requests that will use, in their entirety, the following elements:
---- a) synchronized subrequests involving at least 3 tables
---- b) unsynchronized subrequests in the FROM clause
---- c) groupings of data, group functions, group-level filtering with unsynchronized subrequests (in the HAVING clause) where 
---- at least 3 tables intervene (within the same request)
---- d) orders and the use of NVL and DECODE functions (within the same request)
---- e) the use of at least 2 functions on character strings, 2 functions on calendar dates, at least one CASE expression
---- f) use of at least 1 request block (WITH clause)



-- 1) Display, for each order, the name and surname of the corresponding customer, 
-- and then the type of delivery, the price of the order (which we will call the subtotal), the cost of 
-- delivery (courier: 18.00, post: 10.00, in-store pickup: 0.00), and finally the total payment. 
-–-- subpoints: f) WITH, d) ORDER BY, NVL, DECODE in the same request

WITH LIVRARI AS (
    SELECT 
        C.ID_CLIENT,
        C.LIVRARE,
        DECODE(UPPER(C.LIVRARE),
            'CURIER', 18.00,
            'POSTA', 10.00,
            'PERSONAL', 0.00
        ) AS COST_LIVRARE,
        NVL(C.PRET, 0) AS SUBTOTAL,
        DECODE(UPPER(C.LIVRARE), 
            'CURIER', NVL(C.PRET, 0)+18.00,
            'PERSONAL', NVL(C.PRET, 0),
            'POSTA', NVL(C.PRET, 0)+10.0) AS TOTAL
    FROM COMENZI C
)
SELECT 
    CL.NUME,
    CL.PRENUME,
    L.LIVRARE,
    L.SUBTOTAL,
    L.COST_LIVRARE,
    L.TOTAL
FROM LIVRARI L
JOIN CLIENTI CL ON CL.ID_CLIENT = L.ID_CLIENT
ORDER BY CL.NUME;



-- 2) Display the full name (concatenation between first and last name) of the customer and id, price, 
-- and the order's number of products for all customers whose order had at least one task 
-- for at least one product a designer hired more than 4 years ago.
---- sub-points: a) synchronized subrequests, e) functions on strings and functions on calendar dates

WITH NRPROD AS (
    SELECT 
        C2.ID_COMANDA,
        COUNT(P2.ID_PRODUS) NR_PRODUSE
    FROM COMENZI C2
    JOIN PRODUSE P2 ON C2.ID_COMANDA = P2.ID_COMANDA
    GROUP BY C2.ID_COMANDA
)
SELECT
    CONCAT(CONCAT(UPPER(CL.NUME),' '), UPPER(CL.PRENUME)) AS NUME_COMPLET,
    C.ID_COMANDA,
    C.PRET,
    NP.NR_PRODUSE
FROM CLIENTI CL
JOIN COMENZI C ON C.ID_CLIENT = CL.ID_CLIENT
JOIN NRPROD NP ON NP.ID_COMANDA = C.ID_COMANDA
WHERE EXISTS (
    SELECT *
    FROM COMENZI C1
    JOIN PRODUSE P1 ON P1.ID_COMANDA = C1.ID_COMANDA
    JOIN SARCINI S1 ON S1.ID_PRODUS = P1.ID_PRODUS
    JOIN DESIGNERI D1 ON D1.ID_DESIGNER = S1.ID_DESIGNER
    JOIN ANGAJATI A1 ON A1.ID_ANGAJAT = D1.ID_ANGAJAT
    WHERE C1.ID_CLIENT = CL.ID_CLIENT
      AND MONTHS_BETWEEN(ROUND(SYSDATE), A1.DATA_ANGAJARE) > 48
);



-- 3) To display the name of the materials, the distributor (supplier) and its fiscal code, 
-- and contract signing date for all materials that have signed contracts beginning January 1, 2024. 
---- sub-points: b) unsynchronized sub-request in FROM clause

SELECT DISTINCT
    TAB.NUME_MATERIAL, TAB.NUME DISTRIBUITOR, TAB.COD_FISCAL, TAB.DATA DATA_CONTRACT
FROM (
    SELECT DISTINCT
        M.ID_MATERIAL, M.NUME NUME_MATERIAL, F.NUME, F.COD_FISCAL, C.DATA
    FROM MATERIALE M
    JOIN CONTRACTE C ON M.ID_MATERIAL = C.ID_MATERIAL
    JOIN FURNIZORI F ON C.ID_FURNIZOR = F.ID_FURNIZOR
    WHERE C.DATA >= TO_DATE('2024-01-01', 'YYYY-MM-DD')
) TAB;



-- 4) Display the id of each order, its total amount, the total number of patterns used for the products 
-- them and the number of different materials for it, but only for orders that comply with the following rules:
---- i) The total amount must be greater than the average of the total product amounts for all orders;
---- ii) The total number of patterns associated with the order must be greater than the average of the total number of patterns for all orders.
---- - sub-points: c)

SELECT 
    CL.NUME,
    CL.PRENUME,
    C.ID_COMANDA, 
    C.PRET,

    COUNT(T.ID_TIPAR) NR_TIPARE,
    COUNT(DISTINCT M.ID_MATERIAL) NR_MATERIALE_UNICE
FROM COMENZI C
JOIN CLIENTI CL ON C.ID_CLIENT = CL.ID_CLIENT
JOIN PRODUSE P ON C.ID_COMANDA = P.ID_COMANDA
JOIN TIPARE T ON P.ID_PRODUS = T.ID_PRODUS
JOIN MATERIALE M ON T.ID_MATERIAL = M.ID_MATERIAL
GROUP BY C.ID_COMANDA, C.PRET, CL.NUME, CL.PRENUME
HAVING 
    C.PRET > (
        SELECT AVG(SUMA_PRODUSE)
        FROM (
            SELECT SUM(P1.PRET) SUMA_PRODUSE
            FROM PRODUSE P1
            GROUP BY P1.ID_COMANDA
        )
    ) 
    AND
    COUNT(T.ID_TIPAR) > (
        SELECT AVG(NR_TIPARE)
        FROM (
            SELECT COUNT(T1.ID_TIPAR) AS NR_TIPARE
            FROM TIPARE T1
            JOIN PRODUSE P2 ON T1.ID_PRODUS = P2.ID_PRODUS
            GROUP BY P2.ID_COMANDA
        )
    );



-- 5) Display the name, surname, city (or cities, on different lines, if the customer has several addresses),
-- quality ('Good', if the grade is higher than 7, and 'Acceptable', otherwise), feedback description, and order status, for customers in Romania who have given a feedback grade 
-- greater than 5 and who have selected 'courier' as their delivery method.
---- - e) CASE

SELECT DISTINCT
    CL.NUME,
    CL.PRENUME,
    A.ORAS,
    CASE
        WHEN F.NOTA >7 THEN 'Buna'
        ELSE 'Acceptabila'
    END CALITATE,
    F.DESCRIERE,
    C.STARE
FROM FEEDBACKURI F
JOIN COMENZI C ON F.ID_COMANDA = C.ID_COMANDA
JOIN CLIENTI CL ON CL.ID_CLIENT = C.ID_CLIENT
JOIN ADRESE A ON A.ID_CLIENT = CL.ID_CLIENT
WHERE UPPER(A.TARA) LIKE 'ROMANIA' 
    AND F.NOTA > 5
    AND UPPER(C.LIVRARE) LIKE 'CURIER';




-- EXERCISE 13
-- Implement 3 update and delete data operations using subqueries.


-- 1) Modify the orders table so that all orders for which there is feedback have the status 'COMPLETED'.

UPDATE COMENZI C
SET C.STARE = 'FINALIZATA'
WHERE EXISTS(
    SELECT *
    FROM FEEDBACKURI F1
    JOIN COMENZI C1 ON C1.ID_COMANDA = F1.ID_COMANDA
);



-- 2) Modify the products table so that all products that are in the orders with the feedback note 
-- less than or equal to 7 to receive a 10% discount.

UPDATE PRODUSE P
SET P.PRET = P.PRET * 0.9
WHERE P.ID_PRODUS IN (
    SELECT P1.ID_PRODUS
    FROM PRODUSE P1
    JOIN COMENZI C1 ON C1.ID_COMANDA = P1.ID_COMANDA
    JOIN FEEDBACKURI F1 ON F1.ID_COMANDA = C1.ID_COMANDA
    WHERE F1.NOTA <=7
);



-- 3) Delete all contracts for non-textile materials.

DELETE 
FROM CONTRACTE C
WHERE C.ID_CONTRACT IN (
    SELECT C1.ID_CONTRACT
    FROM CONTRACTE C1
    JOIN MATERIALE M1 ON M1.ID_MATERIAL = C1.ID_MATERIAL
    WHERE UPPER(M1.TIP) NOT LIKE 'MATERIAL TEXTIL'
);




-- EXERCISE 14
-- Creating a complex visualization. Give an example of an LMD operation allowed on the view
-- respectively and an example of a disallowed LMD operation.


-- 1) Create view:
-- Enunt: Create a view that, for each order, presents the order ID, 
-- the name and surname of the corresponding customer, and then the type of delivery, 
-- order price (called subtotal), delivery cost (courier: 18.00, post: 10.00, 
-- personal pickup: 0.00), and finally the total payment.

CREATE OR REPLACE VIEW 
    PLATI_COMENZI 
AS SELECT 
    C.ID_COMANDA,
    CL.NUME,
    CL.PRENUME,
    C.LIVRARE,
    NVL(C.PRET, 0) AS SUBTOTAL,
    DECODE(UPPER(C.LIVRARE),
        'CURIER', 18.00,
        'POSTA', 10.00,
        'PERSONAL', 0.00
    ) AS COST_LIVRARE,
    DECODE(UPPER(C.LIVRARE), 
        'CURIER', NVL(C.PRET, 0) + 18.00,
        'PERSONAL', NVL(C.PRET, 0),
        'POSTA', NVL(C.PRET, 0) + 10.00
    ) AS TOTAL
FROM COMENZI C
JOIN CLIENTI CL ON CL.ID_CLIENT = C.ID_CLIENT
ORDER BY CL.NUME;


-- 2) Allowed LMD operation:
-- Enunt: Change the view so that for all orders with a subtotal of 0, the delivery mode is 'PERSONAL'.

UPDATE PLATI_COMENZI
SET LIVRARE='PERSONAL'
WHERE SUBTOTAL=0;


-- 3) Illegal LMD operation:

-- UPDATE PLATI_COMENZI
-- SET SUBTOTAL = 200.00
-- WHERE ID_COMANDA = 5;




-- EXERCISE 15
-- Formulated in natural language and implemented in SQL: a query using the outer-join operation 
-- on at least 4 tables, a request using the division operation and a request 
-- which implements top-n analysis.


-- 1) Application that uses the outer-join operation on at least 4 tables:
-- Enunt: For each that costs less than 1000 lei, display the name, price, and, 
-- whether it exists or not (if not, null will be displayed): name and year of the collection 
-- of which it is a part, the name and surname of the customer who purchased it, and in 
-- end the feedback note for the order of which it is a part.

SELECT
    P.NUME NUME_PRODUS,
    P.PRET,
    COL.NUME NUME_COLECTIE,
    COL.AN AN_COLECTIE,
    CL.NUME NUME_CLIENT,
    CL.PRENUME PRENUME_CLIENT,
    F.NOTA NOTA_FEEDBACK
FROM PRODUSE P
LEFT OUTER JOIN COLECTII COL ON COL.ID_COLECTIE = P.ID_COLECTIE
LEFT OUTER JOIN COMENZI COM ON COM.ID_COMANDA = P.ID_COMANDA
LEFT OUTER JOIN CLIENTI CL ON CL.ID_CLIENT = COM.ID_CLIENT
LEFT OUTER JOIN FEEDBACKURI F ON F.ID_COMANDA = COM.ID_COMANDA
WHERE P.PRET < 1000;


-- 2) Operation DIVISION
-- Display ID, first and last name for each "lead" customer 
-- (customers entered in the database, but who do not have any orders).

SELECT CL.ID_CLIENT, CL.NUME, CL.PRENUME
FROM CLIENTI CL
MINUS (
    SELECT DISTINCT C1.ID_CLIENT, CL1.NUME, CL1.PRENUME
    FROM COMENZI C1
    JOIN CLIENTI CL1 ON C1.ID_CLIENT = CL1.ID_CLIENT
);


-- 3) TOP-N analysis
-- To display the ID for the 3 customers who bought as much as possible from the store, 
-- name, surname, and total amount paid.

SELECT TAB.ID_CLIENT, TAB.NUME, TAB.PRENUME, TAB.TOTAL_COMENZI
FROM (
    SELECT CL.ID_CLIENT, CL.NUME, CL.PRENUME, SUM(C.PRET) TOTAL_COMENZI
    FROM CLIENTI CL
    JOIN COMENZI C ON CL.ID_CLIENT=C.ID_CLIENT
    WHERE C.PRET IS NOT NULL
    GROUP BY CL.ID_CLIENT, CL.NUME, CL.PRENUME
    ORDER BY SUM(C.PRET) DESC
) TAB
WHERE ROWNUM <= 3;







