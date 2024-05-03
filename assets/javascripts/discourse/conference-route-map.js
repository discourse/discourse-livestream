export default function () {
  this.route("conference", { path: "/conference" }, function () {
    this.route("index", { path: "/" });
    this.route("agenda");
  });
}
