create database projects;

use projects;

select * from hr;

alter table hr
change column ï»¿id emp_id varchar(20) null;

describe hr;

select birthdate from hr;

set sql_safe_updates = 0;

update hr 
set birthdate = case  
    when birthdate like '%/%' 
        then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')  
    when birthdate like '%-%' and length(birthdate) = 10  
        then date_format(str_to_date(birthdate, '%Y-%m-%d'), '%Y-%m-%d')  
    when birthdate like '%-%' and length(birthdate) = 8  
        then date_format(str_to_date(birthdate, '%m-%d-%y'), '%Y-%m-%d')  
    else birthdate  
end;

alter table hr
modify column birthdate date;
select birthdate from hr;

alter table hr
modify column hire_date date;
select hire_date from hr;

update hr
set hire_date = case
    when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    when hire_date like '%-%' and length(hire_date) = 10 then hire_date
    when hire_date like '%-%' and length(hire_date) = 8 then date_format(str_to_date(hire_date, '%m-%d-%y'), '%Y-%m-%d')
    else null
end;

select hire_date from hr;

select termdate from hr;

update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != ' ';


Select @@sql_mode;
set sql_mode = '';

select termdate from hr;

alter table hr
modify column termdate date;

alter table hr add column age int;

select * from hr;

update hr
set age = timestampdiff(year, birthdate, curdate());

select 
	min(age) as youngest,
    max(age) as oldest
from hr;

select count(*) from hr where age < 18;

select count(*) from hr where termdate > curdate();

select count(*)
from hr
where termdate = '0000-00-00';

select location from hr;


-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count
from hr
where age>= 18 and termdate = '0000-00-00'
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr
where age>=18 and termdate = '0000-00-00'
group by race
order by count(*) desc;

-- 3. What is the age distributuion of employees in the company? 
select 
	min(age) as youngest,
    max(age) as oldest
from hr
where age >=18 and termdate = '0000-00-00';

select case when age>=18 and age <=24 then '18-24'
when age>=25 and age <=34 then '25-34'
when age>=35 and age <=44 then '35-44'
when age>=45 and age <=54 then '45-54'
when age>=55 and age <=64 then '55-64'
else '65+'
end as age_group, gender,
count(*) as  count
from hr
where age>=18 and termdate = '0000-00-00'
group by age_group, gender
order by age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count
from hr
where age>=18 and termdate = '0000-00-00'
group by location;

-- 5. What is the average length of employment of employees who have been terminated?
select  round(avg(datediff(termdate, hire_date))/365,0) as avg_length_employment
from hr
where termdate <=curdate() and termdate <> '0000-00-00' and age >= 18;


-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by department, gender
order by department;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by jobtitle
order by jobtitle desc;

-- 8. What department has the highest turnover rate?
select department,
total_count,
terminated_count,
terminated_count/total_count as termination_rate
from (
select department,
count(*) as total_count,
sum(case when termdate<> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >= 18
group by department
) as subquery
order by termination_rate desc;


-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by location_state
order by count desc;

-- 10. How was the company's employee count changed over time based on hire and term dates?
select
year,
hires,
terminations,
hires - terminations as net_change,
round((hires - terminations)/hires*100,2) as net_change_percent
from (
select year(hire_date) as year,
count(*) as hires,
sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations
from hr
where age >= 18
group by year(hire_date)
) as subquery
order by year asc;

-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate<=curdate() and termdate <> '0000-00-00' and age >= 18
group by department;