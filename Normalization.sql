CREATE DATABASE NormalizationDB
GO
USE NormalizationDB
GO 
CREATE TABLE Users (
[Id] INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
[FullName] NVARCHAR(50) NOT NULL DEFAULT 'NO FULLNAME',
[Age] INT NOT NULL
)
GO
CREATE TABLE Posts (
[Id] INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
[Content] NVARCHAR(50) NOT NULL DEFAULT 'NO CONTENT',
[UserId] INT NOT NULL,
CONSTRAINT FK_UserId1 FOREIGN KEY ([UserId]) REFERENCES Users(Id)
)
GO
CREATE TABLE PostRatings (
[Id] INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
[Point] INT NOT NULL ,
[UserId] INT NOT NULL,
[PostId] INT NOT NULL,
CONSTRAINT CK_Point1 CHECK ([Point] BETWEEN 1 AND 5),
CONSTRAINT FK_UserId2 FOREIGN KEY ([UserId]) REFERENCES Users(Id),
CONSTRAINT FK_PostId1 FOREIGN KEY ([PostId]) REFERENCES Posts(Id)
)
GO
CREATE TABLE Comments (
[Id] INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
[Content] NVARCHAR(50) NOT NULL DEFAULT 'NO CONTENT',
[UserId] INT NOT NULL,
[PostId] INT NOT NULL,
[ParentId] INT,
CONSTRAINT FK_UserId3 FOREIGN KEY ([UserId]) REFERENCES Users(Id),
CONSTRAINT FK_PostId2 FOREIGN KEY ([PostId]) REFERENCES Posts(Id),
CONSTRAINT FK_ParentId1 FOREIGN KEY ([ParentId]) REFERENCES Comments(Id)
)
GO
CREATE TABLE CommentRatings (
[Id] INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
[Content] NVARCHAR(50) NOT NULL DEFAULT 'NO CONTENT',
[Point] INT NOT NULL ,
[UserId] INT NOT NULL,
[CommentId] INT NOT NULL,
CONSTRAINT CK_Point2 CHECK ([Point] BETWEEN 1 AND 5),
CONSTRAINT FK_UserId4 FOREIGN KEY ([UserId]) REFERENCES Users(Id),
CONSTRAINT FK_CommentId1 FOREIGN KEY ([CommentId]) REFERENCES Comments(Id)
)
GO
ALTER TABLE Posts
DROP CONSTRAINT FK_UserId1
GO
ALTER TABLE Posts
ADD CONSTRAINT FK_UserId1 FOREIGN KEY ([UserId]) REFERENCES Users(Id) ON UPDATE CASCADE ON DELETE CASCADE
GO
ALTER TABLE PostRatings
DROP CONSTRAINT  FK_PostId1
GO
ALTER TABLE PostRatings
ADD CONSTRAINT FK_PostId1 FOREIGN KEY ([PostId]) REFERENCES Posts(Id) ON UPDATE CASCADE ON DELETE CASCADE 
GO
ALTER TABLE Comments
DROP CONSTRAINT  FK_PostId2
GO
ALTER TABLE Comments
ADD CONSTRAINT FK_PostId2 FOREIGN KEY ([PostId]) REFERENCES Posts(Id) ON UPDATE CASCADE ON DELETE CASCADE 
GO
ALTER TABLE CommentRatings
DROP CONSTRAINT FK_CommentId1
GO
ALTER TABLE CommentRatings
ADD CONSTRAINT FK_CommentId1 FOREIGN KEY ([CommentId]) REFERENCES Comments(Id) ON UPDATE CASCADE ON DELETE CASCADE 
GO
INSERT INTO Users (FullName, Age) VALUES
('John Doe', 28),
('Jane Smith', 24),
('Michael Brown', 32);
GO
INSERT INTO Posts (Content, UserId) VALUES
('Getting started with SQL queries', 1),
('The weather is perfect for a walk', 2),
('Is learning Python worth it in 2024?', 3);
GO
INSERT INTO PostRatings (Point, UserId, PostId) VALUES
(5, 2, 1),
(4, 3, 1),
(5, 1, 2);
GO
INSERT INTO Comments (Content, UserId, PostId, ParentId) VALUES
('Very helpful explanation, thanks!', 2, 1, NULL),
('I totally agree with this point.', 3, 1, NULL),
('It really is a beautiful day.', 1, 2, NULL);
GO
INSERT INTO Comments (Content, UserId, PostId, ParentId) VALUES
('Glad you found it useful!', 1, 1, 1),
('Spot on, Michael!', 2, 1, 2);
GO
INSERT INTO CommentRatings (Content, Point, UserId, CommentId) VALUES
('Great insight', 5, 3, 1),
('Well said', 4, 1, 2),
('Thanks for the reply', 5, 2, 4);
GO
--1.show users,posts
SELECT *
FROM Users AS U
INNER JOIN Posts AS P
ON P.[UserId] = U.[Id]

GO

-- 2. Show the title and average rating for each post
SELECT P.[Content] AS [Post's Names], PR.[PostId] AS [Post's Ratings]
FROM Posts AS P
INNER JOIN PostRatings AS PR
ON PR.[PostId] = P.[Id]

GO

-- 3. Display all comments along with their child comments
SELECT C.[Content] AS [Parent Comment's Content], C.[Id] AS [Parent Comment's Id], [CC].Content AS [ Child Comment's Content], [CC].[ParentId] AS [Child Comment's ParentId]
FROM ( SELECT C.[Content] AS [Content], C.[ParentId]
       FROM Comments AS C
       WHERE C.[ParentId] IS NOT NULL
     ) AS [CC], Comments AS C
INNER JOIN CommentRatings AS CR
ON C.[Id] = CR.[CommentId]
WHERE C.[ParentId] IS NULL

GO

--4. Show all child comments for each comment along with their average ratings.
SELECT C.[Content] AS [Child Comment's Content], C.[ParentId], AVG (CR.[Point] ) AS [Child Comment Rating Avg]
FROM Comments AS C
LEFT JOIN CommentRatings AS CR
ON C.[Id] = CR.[CommentId]
WHERE C.[ParentId] IS NOT NULL
GROUP BY C.[ParentId], C.[Content], C.[Id]
GO
-- 5. Display ratings higher than the overall average rating of all posts
SELECT  P.[Content] AS [Post's Content], AVG(PR.[Point]) AS [Above-Average Rating]
FROM Posts AS P
INNER JOIN PostRatings AS PR
ON PR.[PostId] = P.[Id]
GROUP BY P.[Id], P.[Content]
HAVING  AVG(PR.[Point]) > (
        SELECT AVG(PR.[Point]) AS [All Post's Rating Avg]
        FROM Posts AS P
        INNER JOIN PostRatings AS PR
        ON PR.[PostId] = P.[Id]
)

GO


-- 6. Display ratings that are higher than the overall average rating of all comments
SELECT C.[Content] AS [Comment's Contents], AVG (CR.[Point] ) AS [Above-Average Rating]
FROM Comments AS C
INNER JOIN CommentRatings AS CR
ON CR.[CommentId] = C.[Id]
GROUP BY  C.[Id], C.[Content]
HAVING AVG (CR.[Point] ) > (
           SELECT AVG (CR.[Point] ) AS [Point]
           FROM Comments AS C
           INNER JOIN CommentRatings AS CR
           ON CR.[CommentId] = C.[Id]
)

GO
-- 7. Display the user with the highest number of posts
SELECT TOP 1 U.[FullName] AS [User With Most Posts]
FROM Users AS U
INNER JOIN Posts AS P
ON P.[UserId] = U.[Id]
GROUP BY P.Id, U.[FullName], U.[Id]
ORDER BY COUNT(P.[Id]) DESC

GO

-- 8. Display the user with the highest post rating and the rating value
SELECT TOP 1 SUM(PR.[Point]) AS [Top Rated Post Score],  U.[FullName] AS [User's Name]
FROM Users AS U
INNER JOIN Posts AS P
ON P.[UserId] = U.[Id]
INNER JOIN PostRatings AS PR
ON PR.[PostId] = P.[Id]
GROUP BY U.[Id], U.[FullName]
ORDER BY SUM(PR.[Point]) DESC 

