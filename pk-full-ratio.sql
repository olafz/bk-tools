/*
 * pt-full-ratio
 *
 * For all tables, report how "full" the primary key is.
 * I.e. how close the maximum value of an auto-increment primary key is
 * to overflowing the auto-increment data type.
 *
 * NOTE: the query below only reports against the 'test' schema.
 * You should use this query only as an example, and customize it.
 *
 * Copyright 2012 Bill Karwin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
use test;
drop table if exists ti;
drop table if exists uti;
drop table if exists si;
drop table if exists usi;
drop table if exists mi;
drop table if exists umi;
drop table if exists i;
drop table if exists ui;
drop table if exists bi;
drop table if exists ubi;

create table ti (id tinyint auto_increment primary key) auto_increment=100;
create table uti (id tinyint unsigned auto_increment primary key) auto_increment=100;
create table si (id smallint auto_increment primary key) auto_increment=10000;
create table usi (id smallint unsigned auto_increment primary key) auto_increment=10000;
create table mi (id mediumint auto_increment primary key) auto_increment=1000000;
create table umi (id mediumint unsigned auto_increment primary key) auto_increment=1000000;
create table i (id int auto_increment primary key) auto_increment=1000000000;
create table ui (id int unsigned auto_increment primary key) auto_increment=1000000000;
create table bi (id bigint auto_increment primary key) auto_increment=10000000000000000;
create table ubi (id bigint unsigned auto_increment primary key) auto_increment=10000000000000000;
*/

select table_name, auto_increment, round(auto_increment*100/max_auto_increment, 2) as pk_full_pct
from (select table_name, column_name, column_type, auto_increment,
case 
when column_type like 'tinyint% unsigned' then pow(2,8)-1
when column_type like 'tinyint%' then pow(2,7)-1
when column_type like 'smallint% unsigned' then pow(2,16)-1
when column_type like 'smallint%' then pow(2,15)-1
when column_type like 'mediumint% unsigned' then pow(2,24)-1
when column_type like 'mediumint%' then pow(2,23)-1
when column_type like 'int% unsigned' then pow(2,32)-1
when column_type like 'int%' then pow(2,31)-1
when column_type like 'bigint% unsigned' then pow(2,64)-1
when column_type like 'bigint%' then pow(2,63)-1
else null
end as max_auto_increment
from information_schema.tables t
join information_schema.columns c using (table_schema,table_name)
join information_schema.key_column_usage k using (table_schema,table_name,column_name)
where t.table_schema = 'test' and k.constraint_name = 'PRIMARY' and auto_increment is not null) dt
order by pk_full_pct desc limit 10;
