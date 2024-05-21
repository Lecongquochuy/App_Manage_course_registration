CREATE PROC PROC_CEK_ACCOUNT
@userName NVARCHAR(50), @passWord NVARCHAR(50)
AS
BEGIN
	SELECT * FROM ACCOUNT WHERE UserName = @userName AND Password = @passWord
END
GO
EXEC PROC_CEK_ACCOUNT @userName='phongdaotao' , @passWord='password'

CREATE PROCEDURE PROC_AddPriority
    @MaDT NVARCHAR(5),
    @TenDT NVARCHAR(20),
    @TiLeGiam FLOAT
AS
BEGIN
    INSERT INTO dbo.DTUUTIEN (MaDT, TenDT, TiLeGiam)
    VALUES (@MaDT, @TenDT, @TiLeGiam);
END
