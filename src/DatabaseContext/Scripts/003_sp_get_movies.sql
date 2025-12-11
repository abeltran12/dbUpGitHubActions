CREATE OR ALTER PROCEDURE SP_GET_MOVIES
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        Title,
        ReleaseDate,
        Rating,
        CreatedAt
    FROM Movies
    ORDER BY ReleaseDate DESC;
END