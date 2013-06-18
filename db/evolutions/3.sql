# Update Contribution
# Modified:
# [String body] to accommodate 512 chars, up from 256 chars
# in:
# /app/models/Contribution.java
 
# --- !Ups
ALTER TABLE Contribution ALTER body VARCHAR(511);

# --- !Downs
ALTER TABLE Contribution ALTER body VARCHAR(255);

