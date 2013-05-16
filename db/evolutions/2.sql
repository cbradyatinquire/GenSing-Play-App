# Update Contribution
# Added:
# [String target]
# [boolean isHit] 
# in:
# /app/models/Contribution.java
 
# --- !Ups
ALTER TABLE Contribution ADD target VARCHAR(1024);

ALTER TABLE Contribution ADD isHit VARCHAR(256);
 
# --- !Downs
ALTER TABLE Contribution DROP target;

ALTER TABLE Contribution DROP isHit;
