-- Concede todos os privilégios ao usuário 'user' no banco de dados 'rpg'
GRANT ALL PRIVILEGES ON rpg.* TO 'user'@'%';
FLUSH PRIVILEGES;

