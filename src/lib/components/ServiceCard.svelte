<script>
  export let title = "Service Title";
  export let description = "Service description goes here.";
  export let imageUrl = ""; // Optional image URL
  export let link = "#"; // Link for more details

  import { gsap } from 'gsap';
  import { onMount } from 'svelte';

  let cardElement;
  let hoverTimeline;

  onMount(() => {
    if (cardElement) {
      hoverTimeline = gsap.timeline({ paused: true })
        .to(cardElement, { scale: 1.03, y: -5, duration: 0.25, ease: 'power1.out' })
        .to(cardElement, { boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)', duration: 0.25 }, 0) // Tailwind shadow-lg equivalent
        .to(cardElement.querySelector('h3'), { color: '#2563EB', duration: 0.25 }, 0); // Tailwind's blue-600
    }
    return () => {
      // Cleanup GSAP animation on component destroy
      if (hoverTimeline) {
        hoverTimeline.kill();
      }
    };
  });

  function handleMouseEnter() {
    if (hoverTimeline) hoverTimeline.play();
  }

  function handleMouseLeave() {
    if (hoverTimeline) hoverTimeline.reverse();
  }
</script>

<div
  bind:this={cardElement}
  class="bg-white rounded-lg shadow-md overflow-hidden transition-shadow duration-300"
  on:mouseenter={handleMouseEnter}
  on:mouseleave={handleMouseLeave}
>
  {#if imageUrl}
    <img src={imageUrl} alt={title} class="w-full h-48 object-cover">
  {#else}
    <div class="w-full h-48 bg-gray-200 flex items-center justify-center">
      <span class="text-gray-500">No Image</span>
    </div>
  {/if}
  <div class="p-6">
    <h3 class="text-2xl font-semibold text-gray-800 mb-3">{title}</h3>
    <p class="text-gray-600 mb-4 min-h-[60px]">{description}</p>
    <a href={link} class="inline-block bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded transition-colors duration-300">
      Learn More
    </a>
  </div>
</div>

<style>
  /* Add any specific styles for ServiceCard if Tailwind isn't enough */
  /* min-h-[60px] for description paragraph to maintain some card height consistency */
</style>
