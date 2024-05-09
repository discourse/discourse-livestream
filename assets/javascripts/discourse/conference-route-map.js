export default function () {
  this.route("conference", function () {
    this.route("index", { path: "/" });
    this.route("agenda");
  });
}
