/*
 * Generate SQL statements to find orphaned rows for all relationships
 * described by foreign keys in the INFORMATION_SCHEMA.
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

SELECT CONCAT(
 'SELECT ', GROUP_CONCAT(DISTINCT CONCAT(K.CONSTRAINT_NAME, '.', P.COLUMN_NAME, 
  ' AS `', P.TABLE_SCHEMA, '.', P.TABLE_NAME, '.', P.COLUMN_NAME, '`') ORDER BY P.ORDINAL_POSITION), ' ',
 'FROM ', K.TABLE_SCHEMA, '.', K.TABLE_NAME, ' AS ', K.CONSTRAINT_NAME, ' ',
 'LEFT OUTER JOIN ', K.REFERENCED_TABLE_SCHEMA, '.', K.REFERENCED_TABLE_NAME, ' AS ', K.REFERENCED_TABLE_NAME, ' ',
 ' ON (', GROUP_CONCAT(CONCAT(K.CONSTRAINT_NAME, '.', K.COLUMN_NAME) ORDER BY K.ORDINAL_POSITION),
 ') = (', GROUP_CONCAT(CONCAT(K.REFERENCED_TABLE_NAME, '.', K.REFERENCED_COLUMN_NAME) ORDER BY K.ORDINAL_POSITION), ') ',
 'WHERE ', K.REFERENCED_TABLE_NAME, '.', K.REFERENCED_COLUMN_NAME, ' IS NULL;'
 ) AS _SQL
 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE K
 INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE P
 ON (K.TABLE_SCHEMA, K.TABLE_NAME) = (P.TABLE_SCHEMA, P.TABLE_NAME)
 AND P.CONSTRAINT_NAME = 'PRIMARY'
 WHERE K.REFERENCED_TABLE_NAME IS NOT NULL
 GROUP BY K.CONSTRAINT_NAME;
