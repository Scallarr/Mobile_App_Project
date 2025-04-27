const mysql = require('mysql2');
const con = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'mobilepro (1)'
});

module.exports = con;