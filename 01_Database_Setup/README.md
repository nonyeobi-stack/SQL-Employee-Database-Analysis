Database Environment & Source Attribution

​The dataset used for this analysis is the Temporal Employee Sample Database, a widely recognized industry benchmark for testing complex relational queries and big data performance.

​📜 Attribution & Metadata

​This dataset is a fabricated, large-scale relational database originally designed for temporal data testing.

​Original Data Authors: Fusheng Wang and Carlo Zaniolo (University of Southern Denmark / UCLA)

​Schema Design & Maintenance: Giuseppe Maxia and Patrick Crews

​Copyright: MySQL AB (2007-2008)

​License: Creative Commons Attribution-Share Alike 3.0

​🏗️ Schema Overview

​Upon installation, the database initializes 6 primary tables containing over 300,000 employee records and over 950,000 salary entries. This relational structure is ideal for demonstrating advanced JOIN logic and data aggregation.

​🚀 Setup Instructions

​Due to the file size (approx. 160MB uncompressed), the raw SQL dump is not hosted in this repository. To replicate the analysis environment:

​Download the source files from the Official GitHub Repository 'https://www.dropbox.com/s/znmjrtlae6vt4zi/employees.sql?dl=0.'

​Execute the employees.sql script within your local MySQL instance.

​Ensure all 6 tables (employees, departments, dept_emp, dept_manager, titles, and salaries) are populated before running the analysis scripts in this portfolio.
