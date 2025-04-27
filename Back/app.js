const express = require("express");
const bcrypt = require("bcrypt");
const session = require('express-session');
const app = express();
const con = require("./config/db");
const jwt = require('jsonwebtoken');
const multer = require("multer");
const JWT_KEY = 'm0bile2Simple';
const path = require("path");
const fs = require("fs");
const connection = require("./config/db");
const yaml = require('js-yaml');
const moment = require('moment-timezone');


 
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); 

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDirectory = path.join('C:', 'Users', 'Kasidit', 'Desktop', 'Back_Userrole', 'font', 'project7', 'project7','Assets','image'); // โฟลเดอร์เก็บรูป
    
    // สร้างโฟลเดอร์เก็บรูป ถ้ายังไม่มี
    if (!fs.existsSync(uploadDirectory)) {
      fs.mkdirSync(uploadDirectory, { recursive: true });
      console.log('ไดเรกทอรี image ถูกสร้างขึ้นแล้ว');
    }
    
    cb(null, uploadDirectory);  
  },
  filename: function (req, file, cb) {
    const uploadDirectory = path.join('C:', 'Users', 'Kasidit', 'Desktop', 'Back_Userrole', 'font', 'project7', 'project7','Assets','image');
    
    // หาชื่อไฟล์ที่มีอยู่แล้วในโฟลเดอร์ image
    fs.readdir(uploadDirectory, (err, files) => {
      if (err) throw err;

      // ลำดับชื่อรูป เช่น image1,image2
      let nextFileNumber = 1;
      while (files.includes(`image${nextFileNumber}${path.extname(file.originalname)}`)) {
        nextFileNumber++;
      }

      // กำหนดชื่อไฟล์ใหม่เป็น image1, image2, image3, ...
      const newFilename = `image${nextFileNumber}${path.extname(file.originalname)}`;
      cb(null, newFilename);
    });
  }
});

// สร้างตัวแปร upload เพื่อเรียกใช้function
const upload = multer({ storage: storage });

module.exports = upload;

// Middleware สำหรับตรวจสอบ token
function verifyToken(req, res, next) {
  const token = req.header('Authorization');
  console.log("Received Token: ", token); // ล็อกโทเค็นเพื่อเช็ค
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, JWT_KEY);
    console.log("Decoded user ID: ", decoded.userId); // แสดง decoded userId
    req.user = decoded; // เก็บข้อมูลผู้ใช้ใน req.user
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

// ใช้ middleware ใน route
app.use('/user/history', verifyToken);

app.use(express.json());

// ------------- Login ----------------
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  const sql = "SELECT id, role, password FROM users WHERE username=?";

  con.query(sql, [username], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }

    if (results.length !== 1) {
      return res.status(401).send("Wrong username or password");
    }

    bcrypt.compare(password, results[0].password, (err, same) => {
      if (err) {
        console.error("Error:", err);
        return res.status(500).send("Server error");
      }

      if (same) {
        // สร้าง payload ใหม่เพื่อรวม userId และ role
        const payload = {
          userId: results[0].id, 
          role: results[0].role
        };

        // สร้าง JWT token กะ payload
        const token = jwt.sign(payload, JWT_KEY, { expiresIn: '1d' });

        // ส่งข้อมูลผู้ใช้และ token กลับไป
        res.json({
          userId: results[0].id,
          role: results[0].role,
          token
        });
      } else {
        res.status(401).send("Wrong password");
      }
    });
  });
});


// -------------------- Register --------------------
app.post('/register', function (req, res) {
  const { fullname, username, password, confirmPassword } = req.body;

  // ตรวจสอบว่ารหัสผ่านทั้งสองตรงกันป่าว
  if (password !== confirmPassword) {
    return res.status(400).json({ error: "Passwords do not match" });
  }

  // ตรวจสอบว่า username มีอยู่ในdatabase มั้ย
  const checkUsernameQuery = "SELECT * FROM users WHERE username = ?";
  con.query(checkUsernameQuery, [username], function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Error while checking username" });
    }

    // ถ้าusername ซ้ำ
    if (results.length > 0) {
      return res.status(400).json({ error: "Username already exists" });
    }

    // ถ้า username ไม่ซ้ำ, ทำการแฮชรหัสผ่านแล้วบันทึก database
    bcrypt.hash(password, 10, function (err, hash) {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: "Error while hashing password" });
      }

      // ข้อมูลผู้ใช้ใหม่
      const sql = "INSERT INTO users (fullname, password, username, role) VALUES (?, ?, ?, 1)";
      con.query(sql, [fullname, hash, username], function (err, _same) {
        if (err) {
          console.error(err);
          return res.status(500).send('Server error2');
        } else {
          res.send('Register success !!');
        }
      });
    });
  });
});

//================================================  User role ==================================================//

// -------------------- Home --------------------
app.get('/home', verifyToken, function (_req, res) {
  const userId = req.user.userId;

  const sql = "SELECT * FROM categories";
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});



// -------------------- Show Assets --------------------
app.get('/user/assets', verifyToken,function (_req, res) {
  const sql = `SELECT 
          movies.id AS movie_id,
          movies.movie_name,
          movies.description,
          movies.status_movie,
          movies.pic,
          categories.categorie AS category_name
      FROM 
          movies 
      JOIN 
          categories ON movies.categorie = categories.cate_id;
  `;
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});


// -------------------- Borrow_user --------------------

// แปลงวันที่ที่ส่งมาจาก frontend (DD/MM/YYYY) เป็น (YYYY-MM-DD)
function convertDateToISOFormat(dateStr) {
  const parts = dateStr.split('/'); // แยกวันที่ออกมา
  const day = parts[0];
  const month = parts[1];
  const year = parts[2];

  // สร้างวันที่ในรูปแบบ YYYY-MM-DD
  return `${year}-${month}-${day}`;
}

app.post('/user/borrow/:borrowerId', verifyToken, (req, res) => {
  const { date_end, movie_id } = req.body;  // รับค่า date_return กับ movie_id
  const { borrowerId } = req.params;
  const date_start = new Date().toISOString().split('T')[0];  // วันที่เริ่มต้น (ปัจจุบัน)

  if (!movie_id || isNaN(movie_id)) {
    return res.status(400).json({ error: "Invalid movie_id" });
  }

  // แปลงวันที่ 'date_end' ที่ได้รับจาก Front (DD/MM/YYYY) เป็น YYYY-MM-DD
  const formattedDateEnd = convertDateToISOFormat(date_end);

  console.log("Received borrow data:", { movie_id, borrowerId, date_start, date_end: formattedDateEnd });

  const sqlInsertBorrow = `
    INSERT INTO borrow (movie_id, borrower, date_start, date_end, status)
    VALUES (?, ?, ?, ?, 2)
  `;

  const sqlUpdateMovieStatus = `
    UPDATE movies SET status_movie = 3 WHERE id = ?
  `;

  con.query(sqlInsertBorrow, [movie_id, borrowerId, date_start, formattedDateEnd], (err, result) => {
    if (err) {
      console.error("Error inserting borrow request:", err);
      return res.status(500).json({ error: "Database error" });
    }

    con.query(sqlUpdateMovieStatus, [movie_id], (err) => {
      if (err) {
        console.error("Error updating movie status:", err);
        return res.status(500).json({ error: "Failed to update movie status" });
      }
      res.status(201).json({ message: "Borrow request created and movie status updated", borrowId: result.insertId });
    });
  });
});


// ===================== User History =========================
app.get('/user/history', verifyToken, function (req, res) {
  const userId = req.user.userId; // ดึง userId จาก token ที่ verify แล้ว
  console.log("Fetching history for user ID:", userId); // log ดู ID

  const sql = `
    SELECT 
        movies.movie_name AS book_name,
        movies.id AS movie_ID,
        movies.pic AS movie_picture,
        DATE_FORMAT(borrow.date_start, '%Y-%m-%d') AS borrowed_date, 
        DATE_FORMAT(borrow.date_end, '%Y-%m-%d') AS returned_date,   
        returned_users.fullname AS returned_Named,
        approver_users.fullname AS approver_Named,
        status.status_name AS status
    FROM 
        borrow
    LEFT JOIN 
        movies ON borrow.movie_id = movies.id 
    LEFT JOIN 
        users AS approver_users ON borrow.approver = approver_users.id
    LEFT JOIN 
        users AS returned_users ON borrow.admin = returned_users.id
    LEFT JOIN 
        status ON borrow.status = status.id
    WHERE 
        borrow.borrower = ?;
  `;

  con.query(sql, [userId], function (err, results) {
    if (err) {
      console.error("Error fetching borrowing history:", err);
      return res.status(500).send('Server error');
    }

    res.json(results);
  });
});



//===============================================Approver Role ====================================================//


// -------------------- Home ------------------------//
app.get('/approver/home', verifyToken, function (_req, res) {
  const userId = req.user.userId;

  const sql = "SELECT * FROM categories";
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});


// -------------------- Show Assets --------------------//
app.get('/approver/asset', function (_req, res) {
  const sql = `SELECT 
          movies.id AS movie_id,
          movies.movie_name,
          movies.description,
          movies.status_movie,
          movies.pic,
          categories.categorie AS category_name
      FROM 
          movies 
      JOIN 
          categories ON movies.categorie = categories.cate_id;
  `;
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});


//--------------------------- Approve page --------------------//
app.get('/approver/confirm', verifyToken, function (req, res) {
  const sql = `
    SELECT 
      borrow.id AS borrow_id,  -- ดึง borrow id
      movies.movie_name AS movie_name,
      movies.id AS movie_id,  -- ดึง movie id
      movies.pic AS movie_pic ,
      borrow.date_start AS borrowed_date,
      borrow.date_end AS returned_date,
      returned_users.fullname AS borrower_name
    FROM 
      borrow
    LEFT JOIN 
      movies ON borrow.movie_id = movies.id
    LEFT JOIN 
      users AS returned_users ON borrow.borrower = returned_users.id
    WHERE 
      borrow.status = (SELECT id FROM status WHERE status_name = 'pending');
  `;

  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);  // ส่งข้อมูลที่ดึงออกมาจากฐานข้อมูลไปให้ผู้ใช้
    console.log(results);  // แสดงผลใน console เพื่อการตรวจสอบ
  });
});


//--------------------------- Approve  and reject confirm page --------------------//
app.post('/approver/confirm/:borrowId', verifyToken, function (req, res) {
  const approverId = req.user.userId;  // ดึง approverId จาก body
  const borrowId = req.params.borrowId;    // ดึง borrowId จาก params
  const status = req.body.status;          // ดึง status (approved หรือ rejected) จาก body

  // ตรวจสอบว่ามี borrowId, approverId หรือ status หรือไม่
  if (!borrowId || !approverId || !status) {
      return res.status(400).send('Missing borrowId, approverId or status in request.');
  }

  // แปลง status จาก approve/rejected ไปเป็น status_id
  let statusId;
  let movieStatusId;
  if (status === 'approved') {
      statusId = 1;  // ค่าของ status_id สำหรับ approved
      movieStatusId = 4;  // ค่าของ status_movie สำหรับ approved (4)
  } else if (status === 'rejected') {
      statusId = 3;  // ค่าของ status_id สำหรับ rejected
      movieStatusId = 1;  // ค่าของ status_movie สำหรับ rejected (1)
  } else {
      return res.status(400).send('Invalid status value.');
  }

  // ตรวจสอบสถานะของ borrowId ว่ามีอยู่และเป็นสถานะที่ต้องการหรือไม่
  const sqlCheckStatus = `
      SELECT id, status FROM borrow WHERE id = ?;
  `;
  
  con.query(sqlCheckStatus, [borrowId], function (err, result) {
      if (err) {
          console.error("Error checking borrow status:", err);
          return res.status(500).send('Error checking borrow status: ' + err.message);
      }
      
      if (result.length === 0) {
          return res.status(404).send('Borrow record not found.');
      }

      const currentStatus = result[0].status;
      if (currentStatus !== 2) {  // ถ้าสถานะไม่ใช่ 2 (pending)
          return res.status(400).send('Borrow record is not in pending status.');
      }

      // เริ่มอัปเดตสถานะของ borrow
      const sqlUpdateBorrow = `
          UPDATE borrow 
          SET 
              status = ?, 
              approver = ? 
          WHERE id = ? 
          AND status = 2;  
      `;

      con.query(sqlUpdateBorrow, [statusId, approverId, borrowId], function (err, result) {
          if (err) {
              console.error("Error updating borrow status:", err);
              return res.status(500).send('Error updating borrow status: ' + err.message);
          }

          if (result.affectedRows === 0) {
              return res.status(404).send('No matching borrow record found or it is not in pending status.');
          }

          // อัปเดตสถานะของหนัง
          const sqlUpdateMovieStatus = `
              UPDATE movies
              SET status_movie = ?
              WHERE id = (SELECT movie_id FROM borrow WHERE id = ?); 
          `;

          con.query(sqlUpdateMovieStatus, [movieStatusId, borrowId], function (err) {
              if (err) {
                  console.error("Error updating movie status:", err);
                  return res.status(500).send('Error updating movie status: ' + err.message);
              }

              res.send('Movie status updated successfully.');
          });
      });
  });
});




// -------------------- Dashboard  -- ------------------------//
app.get('/approver/dashboard', verifyToken,  function (_req, res) {
  const sqlStatus = `
    SELECT 
        ms.status_name, 
        COUNT(m.id) AS total
    FROM 
        movie_status ms
    LEFT JOIN 
        movies m ON ms.status_id = m.status_movie
    GROUP BY 
        ms.status_id;
  `;

  const sqlTotalRooms = `
    SELECT COUNT(*) AS total_rooms FROM movies;
  `;

  // รันคำสั่ง SQL แยกกัน
  con.query(sqlStatus, function (err, statusResults) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }

    con.query(sqlTotalRooms, function (err, roomResults) {
      if (err) {
        console.error(err);
        return res.status(500).send('Server error');
      }

      res.json({
        statusCounts: statusResults.map((status) => ({
          ...status,
          total_rooms: roomResults[0].total_rooms, // เพิ่ม total_rooms ให้แต่ละสถานะ
        })),
        totalRooms: roomResults[0].total_rooms,
      });
      
      console.log(roomResults)
      console.log(statusResults)
      
    });
  });
});




// -------------------- History  -- ------------------------//
function convertDateToISOFormat(dateStr) {
  const parts = dateStr.split('/'); // แยกวันที่ออกมา
  const day = parts[0];
  const month = parts[1];
  const year = parts[2];

  // สร้างวันที่ในรูปแบบ YYYY-MM-DD
  return `${year}-${month}-${day}`;
}

app.get('/approver/history', verifyToken, function (req, res) {
  const approverId = req.user.userId; // ดึง userId จาก token ที่ verify แล้ว
  console.log("Fetching history for user ID:", approverId); // log ดู ID

  const sql = 
  `
    SELECT 
        movies.movie_name AS book_name,
        movies.id AS movie_ID,
        movies.pic AS movie_picture,
        borrow.date_start AS borrowed_date,
        borrow.date_end AS returned_date,
        borrower_users.fullname AS borrower_Named,
        status.status_name AS status
    FROM 
        borrow
    LEFT JOIN 
        movies ON borrow.movie_id = movies.id 
    LEFT JOIN 
        users AS borrower_users ON borrow.borrower = borrower_users.id 
    LEFT JOIN 
        status ON borrow.status = status.id
    WHERE 
        borrow.approver = ?;  -- Filter by approverId
  `;
  
  con.query(sql, [approverId], function (err, results) {
    if (err) {
      console.error("Error fetching borrowing history:", err);
      return res.status(500).send('Server error');
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'No data found for the given approver ID' });
    }

    // Format the dates to "YYYY-MM-DD" format
    results.forEach(row => {
      row.borrowed_date = new Date(row.borrowed_date).toISOString().split('T')[0]; // Extract date only
      row.returned_date = new Date(row.returned_date).toISOString().split('T')[0]; // Extract date only
    });

    res.json(results);
    console.log(results)
  });
});



//========================================== Admin Role========================================//

// -------------------- Home --------------------//
app.get('/home', verifyToken, function (_req, res) {
  const userId = req.user.userId;

  const sql = "SELECT * FROM categories";
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});


// -------------------- Asset  --------------------//
app.get('/admin/asset',verifyToken,function (_req, res) {
  const sql = `SELECT 
          movies.id AS movie_id,
          movies.movie_name,
          movies.description,
          movie_status.status_name AS status_movie,  -- Retrieve status as string
          movies.pic,
          categories.categorie AS category_name
      FROM 
          movies 
      JOIN 
          categories ON movies.categorie = categories.cate_id
      JOIN 
          movie_status ON movies.status_movie = movie_status.status_id;`;  // Join movie_status table
  
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }
    res.json(results);  // Send results as JSON response
    // Log results for debugging
  });
});


// -------------------- Add movies  --------------------//
app.post("/admin/add", upload.single("pic"), function (req, res) {
  const { movie_name, description, categorie, status_movie } = req.body;
  const pic = req.file ? 'Assets/image/' + req.file.filename : null; 


  if (!movie_name || !description || !categorie || !pic) {
    return res.status(400).send("All fields are required.");
  }

  
  const sql = `INSERT INTO movies (movie_name, description, categorie, status_movie, pic) 
               VALUES (?, ?, ?, 1, ?)`;
  const roomValues = [movie_name, description, categorie, pic];

  // Update YAML file
  const yamlFilePath = 'C:/Users/Kasidit/Desktop/Back_Userrole/font/project7/project7/pubspec.yaml';
  try {
    const yamlContent = yaml.load(fs.readFileSync(yamlFilePath, 'utf8'));

    // ตรวจสอบว่า flutter และ assets ถูกกำหนดใน YAML หรือไม่
    if (!yamlContent.flutter || !yamlContent.flutter.assets) {
      if (!yamlContent.flutter) yamlContent.flutter = {}; // ถ้าไม่มี flutter, สร้าง
      yamlContent.flutter.assets = []; // ถ้าไม่มี assets ภายใน flutter, สร้างเป็น array
    }

    // เพิ่มเส้นทางรูปภาพใหม่ลงใน assets
    const normalizedPic = pic.replace(/\\/g, '/'); // เปลี่ยน \ เป็น /
    if (!yamlContent.flutter.assets.includes(normalizedPic)) {
      yamlContent.flutter.assets.push(normalizedPic);
    }

    // เขียนกลับลงใน YAML
    fs.writeFileSync(yamlFilePath, yaml.dump(yamlContent), 'utf8');
    console.log("Updated YAML file successfully");
  } catch (error) {
    console.error("Error updating YAML file:", error);
    return res.status(500).send("Error updating YAML file");
  }

  con.query(sql, roomValues, (err, result) => {
    if (err) {
      console.error("Error inserting movie:", err);
      return res.status(500).send("Error inserting movie into database");
    }

   
    const movieId = result.insertId;
    res.send(`Movie '${movie_name}' added successfully with ID: ${movieId}`);
  });
});


// -------------------- Edit books --------------------//
app.put('/admin/assets/:movieId/edit' , upload.single('pic'), async (req, res) => {
  const movieId = req.params.movieId;

  let picUrl = ''; 
  if (req.file) {
    const fileExtension = path.extname(req.file.originalname);
    let newFileName = 'image' + fileExtension;

   
    picUrl = path.join('Assets', 'imageedit', newFileName);

    let counter = 1;
    while (fs.existsSync(path.join('C:', 'Users', 'Kasidit', 'Desktop', 'Back_Userrole', 'font', 'project7', 'project7', 'Assets', 'imageedit', newFileName))) {
      newFileName = 'image' + counter + fileExtension;
      picUrl = path.join('Assets', 'imageedit', newFileName); // เปลี่ยนแค่ชื่อไฟล์ใหม่
      counter++;
    }

    // ย้ายไฟล์ไปยังตำแหน่งใหม่
    fs.renameSync(req.file.path, path.join('C:', 'Users', 'Kasidit', 'Desktop', 'Back_Userrole', 'font', 'project7', 'project7', picUrl));

    // เปลี่ยน \ เป็น / ในเส้นทาง
    const normalizedPicUrl = picUrl.replace(/\\/g, '/');

    // อัปเดตค่าในไฟล์ YAML
    const yamlFilePath = 'C:/Users/Kasidit/Desktop/Back_Userrole/font/project7/project7/pubspec.yaml';
    try {
      // อ่านไฟล์ YAML
      const yamlContent = yaml.load(fs.readFileSync(yamlFilePath, 'utf8'));

      // ตรวจสอบว่า flutter.assets ถูกกำหนดใน YAML หรือไม่
      if (!yamlContent.flutter || !yamlContent.flutter.assets) {
        if (!yamlContent.flutter) yamlContent.flutter = {}; // ถ้าไม่มี flutter, สร้าง
        yamlContent.flutter.assets = []; // ถ้าไม่มี assets ภายใน flutter, สร้างเป็น array
      }

      // ตรวจสอบว่าไฟล์นี้มีอยู่ใน assets หรือไม่
      const newAssetPath = normalizedPicUrl; // ใช้ path ที่สัมพันธ์กับโปรเจ็กต์
      if (!yamlContent.flutter.assets.includes(newAssetPath)) {
        // ถ้าไม่มี, เพิ่มเข้าไปใน assets ของ flutter
        yamlContent.flutter.assets.push(newAssetPath);
      }

      // เขียนข้อมูลที่อัปเดตแล้วกลับไปยังไฟล์ YAML
      fs.writeFileSync(yamlFilePath, yaml.dump(yamlContent), 'utf8');
      console.log('YAML file updated successfully');
    } catch (error) {
      console.error('Error updating YAML file:', error);
    }

    // แปลงเส้นทางให้เป็น / ก่อนบันทึกในฐานข้อมูล
    picUrl = picUrl.replace(/\\/g, '/');  // แทนที่ \ ด้วย /

    // ทำการอัปเดตข้อมูลในฐานข้อมูล (สมมติว่ามีฟังก์ชัน updateMovieInDatabase)
    const { movie_name, description, categorie, status_movie } = req.body.data ? JSON.parse(req.body.data) : {};
    const result = await updateMovieInDatabase(
      movieId, movie_name, description, categorie, status_movie, picUrl
    );

    if (result) {
      res.status(200).send('Movie updated successfully');
    } else {
      res.status(400).send('Error updating movie');
    }
  }
});


// ฟังก์ชันสำหรับอัปเดตในฐานข้อมูล
async function updateMovieInDatabase(movieId, movieName, description, categorie, status, picUrl) {
  const sql = `
    UPDATE movies
    SET movie_name = ?, description = ?, categorie = ?, status_movie = ?, pic = ?
    WHERE id = ?`;

  return new Promise((resolve, reject) => {
    connection.query(sql, [
      movieName,
      description,
      categorie,
      status,
      picUrl || '', // ถ้ามีการอัพโหลดภาพจะมี URL ของภาพ
      movieId
    ], (err, result) => {
      if (err) {
        console.error('Error executing query:', err);
        return reject(err); // ถ้ามีข้อผิดพลาดในการ query ให้ reject
      }
      resolve(result.affectedRows > 0); // ถ้า affectedRows > 0 หมายถึงอัปเดตสำเร็จ
    });
  });
}


//------------------Disable and Enable movies -------------------------// 

app.put('/admin/assets/:movieId/disable', verifyToken,async (req, res) => {
  const movieId = req.params.movieId;
  const { status_movie } = req.body;

  try {
    // อัปเดตสถานะในฐานข้อมูล
    const result = await updateMovieStatus(movieId, status_movie);
console.log('Movie Id '+movieId);
console.log('status ' +  status_movie);
    if (result) {
      res.status(200).send('Status updated successfully');
    } else {
      res.status(400).send('Error updating status');
    }
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
});

// ฟังก์ชันสำหรับอัปเดตสถานะ
async function updateMovieStatus(movieId, status) {
  const sql = `
    UPDATE movies
    SET status_movie = ?
    WHERE id = ?`;

  return new Promise((resolve, reject) => {
    connection.query(sql, [status, movieId], (err, result) => {
      if (err) {
        console.error('Error executing query:', err);
        return reject(err);
      }
      resolve(result.affectedRows > 0); // ตรวจสอบว่าแถวถูกอัปเดต
    });
  });
}

//------------------Return page  -------------------------// 
app.get('/admin/return', function (req, res) {
  const sql = `
  SELECT 
    borrow.id AS borrow_id, 
    movies.pic AS movie_image, 
    movies.movie_name AS movie_name, 
    movies.id AS movie_id, 
    borrow.date_start AS borrowed_date, 
    borrow.date_end AS returned_date, 
    users.fullname AS borrower_name
  FROM 
    borrow
  LEFT JOIN 
    movies ON borrow.movie_id = movies.id
  LEFT JOIN 
    users ON borrow.borrower = users.id
  WHERE 
    borrow.status = 1;
  `;

  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }

    // แปลงวันที่ให้ตรงกับ Time Zone ของไทย
    results.forEach(row => {
      row.borrowed_date = moment(row.borrowed_date).tz('Asia/Bangkok').format('YYYY-MM-DD');
      row.returned_date = moment(row.returned_date).tz('Asia/Bangkok').format('YYYY-MM-DD');
    });

    res.json(results);
    console.log(results);
  });
});

//--------------------------- Confirm return page --------------------------//
app.post('/admin/return/:borrowId', verifyToken, function (req, res) {
  const borrowId = req.params.borrowId; // Get borrowId from URL
  const adminId = req.user.userId; // Extract adminId from token

  // Validate input
  if (!borrowId || !adminId) {
      return res.status(400).send('Borrow ID and Admin ID are required.');
  }

  const currentDate = new Date().toISOString().split('T')[0]; // Get today's date

  // SQL to update the borrow record's status to 'returned' (4)
  const sqlUpdateBorrow = `
      UPDATE borrow 
      SET status = 4, 
          date_end = ?, 
          admin = ?
      WHERE id = ? AND status = 1;
  `;

  // SQL to update the movie's status to 'available' (1)
  const sqlUpdateMovieStatus = `
      UPDATE movies 
      SET status_movie = 1
      WHERE id = (SELECT movie_id FROM borrow WHERE id = ? AND status = 4);
  `;

  // Start transaction
  con.beginTransaction(function (err) {
      if (err) {
          console.error("Error starting transaction:", err);
          return res.status(500).send('Error starting transaction: ' + err.message);
      }

      // First, update the borrow status
      con.query(sqlUpdateBorrow, [currentDate, adminId, borrowId], function (err, result) {
          if (err) {
              return con.rollback(() => {
                  console.error("Error updating borrow status:", err);
                  return res.status(500).send('Error updating borrow status: ' + err.message);
              });
          }

          // Check if any rows were affected (meaning the update was successful)
          if (result.affectedRows === 0) {
              return con.rollback(() => {
                  return res.status(404).send('Borrow record not found or already returned.');
              });
          }

          // Then, update the movie status
          con.query(sqlUpdateMovieStatus, [borrowId], function (err) {
              if (err) {
                  return con.rollback(() => {
                      console.error("Error updating movie status:", err);
                      return res.status(500).send('Error updating movie status: ' + err.message);
                  });
              }

              // Commit the transaction
              con.commit(function (err) {
                  if (err) {
                      return con.rollback(() => {
                          console.error("Error committing transaction:", err);
                          return res.status(500).send('Error committing transaction: ' + err.message);
                      });
                  }
                  res.send('Movie returned successfully.'); // Success response
              });
          });
      });
  });
});


// -------------------- Dashboard  -- ------------------------//
app.get('/admin/dashboard', verifyToken,  function (_req, res) {
  const sqlStatus = `
    SELECT 
        ms.status_name, 
        COUNT(m.id) AS total
    FROM 
        movie_status ms
    LEFT JOIN 
        movies m ON ms.status_id = m.status_movie
    GROUP BY 
        ms.status_id;
  `;

  const sqlTotalRooms = `
    SELECT COUNT(*) AS total_rooms FROM movies;
  `;

  // รันคำสั่ง SQL แยกกัน
  con.query(sqlStatus, function (err, statusResults) {
    if (err) {
      console.error(err);
      return res.status(500).send('Server error');
    }

    con.query(sqlTotalRooms, function (err, roomResults) {
      if (err) {
        console.error(err);
        return res.status(500).send('Server error');
      }

      res.json({
        statusCounts: statusResults.map((status) => ({
          ...status,
          total_rooms: roomResults[0].total_rooms, // เพิ่ม total_rooms ให้แต่ละสถานะ
        })),
        totalRooms: roomResults[0].total_rooms,
      });
      
      console.log(roomResults)
      console.log(statusResults)
      
    });
  });
});

// -------------------- History  -- ------------------------//
app.get('/admin/history', verifyToken, function (req, res) {
  console.log("Fetching all borrowing history...");

  const sql = 
  `
    SELECT 
        movies.movie_name AS book_name,
        movies.id AS movie_ID,
        movies.pic AS movie_picture,
        borrow.date_start AS borrowed_date,
        borrow.date_end AS returned_date,
        borrower_users.fullname AS borrower_name,
        approver_users.fullname AS approver_name,
        admin_users.fullname AS admin_name,
        status.status_name AS status
    FROM 
        borrow
    LEFT JOIN 
        movies ON borrow.movie_id = movies.id 
    LEFT JOIN 
        users AS borrower_users ON borrow.borrower = borrower_users.id 
    LEFT JOIN 
        users AS approver_users ON borrow.approver = approver_users.id 
    LEFT JOIN 
        users AS admin_users ON borrow.admin = admin_users.id 
    LEFT JOIN 
        status ON borrow.status = status.id;
  `;
  
  con.query(sql, function (err, results) {
    if (err) {
      console.error("Error fetching borrowing history:", err);
      return res.status(500).send('Server error');
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'No data found for the given criteria' });
    }

    // Format the dates to "YYYY-MM-DD" format
    results.forEach(row => {
      row.borrowed_date = new Date(row.borrowed_date).toISOString().split('T')[0]; // Extract date only
      row.returned_date = new Date(row.returned_date).toISOString().split('T')[0]; // Extract date only
    });

    res.json(results);
    console.log(results);
  });
});


//=================================================================== End ============================================================================//


// -------------------- Server Port --------------------
const port = 3000;
app.listen(port, function () {
  console.log("Server is ready at " + port);
});
