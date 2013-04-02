crypto = require('crypto');

SaltLength = 9;

createHash = (password) -> {
  salt = generateSalt(SaltLength);
  hash = md5(password + salt);
  return salt + hash;
}

# determines if a password is equal to a given hash
validateHash = (hash, password) -> 
  salt = hash.substr(0, SaltLength);
  validHash = salt + md5(password + salt);
  return hash == validHash;

generateSalt = (len) ->
  set = '0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ',
      setLen = set.length,
      salt = '';
  for (i = 0; i < len; i++) {
    p = Math.floor(Math.random() * setLen);
    salt += set[p];
  }
  return salt;

md5 = (string) ->
  return crypto.createHash('md5').update(string).digest('hex');

module.exports = {
  'hash': createHash,
  'validate': validateHash
};