namespace Api.Models;

public class Movie
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public DateTime ReleaseDate { get; set; }
    public decimal Rating { get; set; }
}