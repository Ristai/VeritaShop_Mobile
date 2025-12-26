const { validationResult } = require('express-validator');
const { errorResponse } = require('../utils/response');

const validate = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const messages = errors.array().map(err => err.msg);
    return errorResponse(res, messages[0], 400, 'VALIDATION_ERROR', messages);
  }
  
  next();
};

module.exports = validate;
