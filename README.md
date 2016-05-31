Geo Service
===========

# Introduction

The Geo Service should provide:

* Regions, Countries, Subdivisions (States, Counties, Territories) including timezones
* Currencies, including default currency per country/region and official language list
* Languages, including English name, native name, countries with official use

# Structure

* DAL Layer
	* Regions
	* Countries
	* Subdivisions
	* Currencies
	* Languages

* Service Layer
	* Regions
	* Countries
	* Subdivisions
	* Currencies
	* Languages

# Resources

As detailed in public/index.html when running.

* /countries
* /regions
* /subdivisions
* /currencies
* /languages

# ENV config

* DATABASE_URL - mysql2://username:password@host:port/dbname

Memcache is optional and will only be used if configured.

* MEMCACHED_HOST - localhost 
* MEMCACHED_PORT - 11211

