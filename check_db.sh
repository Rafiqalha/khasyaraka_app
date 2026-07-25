#!/bin/bash
su - postgres -c "psql -c 'SELECT datname FROM pg_database;'"
