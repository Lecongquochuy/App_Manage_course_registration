CREATE PROC PROC_CEK_ACCOUNT
@userName NVARCHAR(50), @passWord NVARCHAR(50)
AS
BEGIN
	SELECT COUNT(*) FROM ACCOUNT WHERE UserName = @userName AND Password = @passWord
END
GO
EXEC PROC_CEK_ACCOUNT @userName='phongdaotao' , @passWord='password'
