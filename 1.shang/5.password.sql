update mysql.user set password=password('root') where User='root' and Host='localhost' limit 1;

