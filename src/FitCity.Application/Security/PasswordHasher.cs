namespace FitCity.Application.Security;

public static class PasswordHasher
{
    public static string Hash(string password) => $"HASHED:{password}";

    public static bool Verify(string password, string hash) =>
        string.Equals(Hash(password), hash, StringComparison.Ordinal);
}
