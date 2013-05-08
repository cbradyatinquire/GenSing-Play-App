# Update CodeCategory and CodeDescriptor
# Added [String details] in 
# /app/models/CodeCategory.java and 
# /app/models/CodeDescriptor.java
 
# --- !Ups
ALTER TABLE CodeCategory ADD details VARCHAR(8192);

ALTER TABLE CodeDescriptor ADD details VARCHAR(8192);
 
# --- !Downs
ALTER TABLE CodeCategory DROP details;

ALTER TABLE CodeDescriptor DROP details;
