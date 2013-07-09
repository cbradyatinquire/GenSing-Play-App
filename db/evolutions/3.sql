# Update Contribution
# Modified:
# [String body] to accommodate 512 chars, up from 256 chars
# in:
# /app/models/Contribution.java
 
# --- !Ups
ALTER TABLE contribution MODIFY body VARCHAR(512);

# --- !Downs
ALTER TABLE contribution MODIFY body VARCHAR(256);



