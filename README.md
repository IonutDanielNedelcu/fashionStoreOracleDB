Database (Oracle) — Project README

**Notă:** except the .sql files, all the other ones are written completely in Romanian due to the assignment rules

**Project File**
- **Project.pdf:** The Project.pdf file contains the entire project, explained step-by-step, in Romanian. Romanian speakers can read the full explanation and follow the implementation in that document. See [Project.pdf](Project.pdf).

**For English Speakers**
The table names are in Romanian; here are their translations (format: [RO] = [EN]):

- ADRESA = ADDRESS
- CLIENT = CLIENT
- COMANDA = ORDER
- FEEDBACK = FEEDBACK
- PRODUS = PRODUCT
- COLECTIE = COLLECTION
- ANGAJAT = EMPLOYEE
- CROITOR = SEWER
- DESIGNER = DESIGNER
- TIPAR = PATTERN
- MATERIAL = MATERIAL
- FURNIZOR = SUPPLIER

**Diagrams and Details**
- Refer primarily to [ERD.pdf](ERD.pdf) for the entity-relationship diagram.
- The [conceptual_diagram.pdf](conceptual_diagram.pdf) contains all column names in Romanian (39 columns, excluding primary and foreign keys).
- SQL scripts (DDL and data insertion) are provided in create_insert.sql and examples.sql.

**Requirements**
- **1:** Description of the actual model, its utility and operating rules.
- **2:** Presentation of the constraints (restrictions, rules) imposed on the model.
- **3:** Description of the entities, including specifying the primary key.
- **4:** Description of relationships, including specification of their cardinality.
- **5:** Description of attributes, including data type and possible constraints, default values, possible attribute values.
- **6:** Creation of the entity-relationship diagram corresponding to the description in points 3–5.
- **7:** Creation of the conceptual diagram corresponding to the ER diagram designed in point 6. The conceptual diagram must contain at least 7 tables (not including sub-entities), with at least one associative table.
- **8:** Enumeration of the relational schemas corresponding to the conceptual diagram designed in point 7.
- **9:** Perform normalization up to 3rd normal form (1NF–3NF).
- **10:** Create a sequence to be used for inserting records into the tables.
- **11:** Create tables in SQL and insert consistent data into each of them (minimum 5 records in each non-associative table; minimum 10 records in associative tables; maximum 30 records per table).
- **12:** Formulate in natural language and implement 5 complex SQL requests that together include:
	- synchronized subrequests involving at least 3 tables,
	- unsynchronized subrequests in the FROM clause,
	- data groupings, group functions, filtering at group level with unsynchronized subrequests (in HAVING) involving at least 3 tables,
	- orders and the use of NVL and DECODE in the same request,
	- use of at least 2 string functions, 2 date functions, at least one CASE expression,
	- use of at least one WITH clause (request block).
	Note: The 5 requests should, across them, include all the elements listed above.
- **13:** Implement 3 update/delete operations using subqueries.
- **14:** Create a complex view. Provide an example of a permitted LMD operation on that view and an example of a disallowed LMD operation.
- **15:** Formulate in natural language and implement in SQL: an outer-join request across at least 4 tables, a division operation request, and a top‑N analysis request. These three applications must be different from those in exercise 12.

