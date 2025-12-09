-- Migration to add userType field to Users table
-- Run this script manually in MySQL if you encounter foreign key errors

USE vet;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS=0;

-- Make cabinetId nullable
ALTER TABLE Users MODIFY cabinetId INT NULL;

-- Add userType column if it doesn't exist
ALTER TABLE Users ADD COLUMN IF NOT EXISTS userType ENUM('doctor', 'client') NOT NULL DEFAULT 'doctor' AFTER lastName;

-- Update existing users to be doctors (since they all have cabinetId)
UPDATE Users SET userType = 'doctor' WHERE cabinetId IS NOT NULL;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS=1;

-- Verify the changes
SELECT id, username, email, userType, cabinetId FROM Users LIMIT 10;
