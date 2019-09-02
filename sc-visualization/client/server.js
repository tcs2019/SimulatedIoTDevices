/* eslint-disable func-names */
const express = require('express');

const app = express();
const multer = require('multer');
const cors = require('cors');

app.use(cors());

// const storage = multer.diskStorage({
//   destination(req, file, cb) {
//     cb(null, 'public');
//   },
//   filename(req, file, cb) {
//     cb(null, `${Date.now()}-${file.originalname}`);
//   },
// });

// const upload = multer({ storage }).single('file');

app.post('/upload', function(req, res, next) {
  console.log(req.body.address);
  // upload(req, res, function(err) {
  //   if (err instanceof multer.MulterError) {
  //     return res.status(500).json(err);
  //   }
  //   if (err) {
  //     return res.status(500).json(err);
  //   }
  //   return res.status(200).send(req.file);
  // });
});

app.get('/contract', function(req, res, next) {
  // handle request get address & abi
});

app.listen(8000, function() {
  // eslint-disable-next-line no-console
  console.log('App running on port 8000');
});
